
\set ON_ERROR_STOP on

drop table if exists scid_eco cascade;
CREATE TABLE scid_eco (
      openingid     serial          
    , eco           VARCHAR(4)      NOT NULL
    , opening       TEXT            NOT NULL
    , var1          TEXT 
    , var2          TEXT 
    , var3          TEXT 
    , var4          TEXT 
    , var5          TEXT 
    , fen           board           NOT NULL  
    , moves         TEXT            NOT NULL
    , halfmoves     INT             NOT NULL
);

\copy scid_eco (eco, opening, var1, var2, var3, var4, var5, fen, moves, halfmoves) from 'data/scid_eco.dump';

CREATE OR REPLACE FUNCTION opening_suffix(TEXT)
RETURNs TEXT AS
$$
   SELECT 
CASE 
    WHEN 
        $1 LIKE '%Gambit'
        OR $1 LIKE '%Accepted'
        OR $1 LIKE '%Declined'
        OR $1 LIKE '%Defense'
        OR $1 LIKE '%Attack'
        OR $1 LIKE '%System'
        OR $1 LIKE '%Formation'
    THEN $1
    ELSE $1 || ' Variation'
END
$$ LANGUAGE SQL;

/**************************************************
* checks
**************************************************/
/*{{{*/
\echo duplicated openings ...
    SELECT
        COUNT(*)
        , opening
        , halfmoves 
    FROM scid_eco
    WHERE var1 IS NULL 
    GROUP BY opening, halfmoves 
    HAVING COUNT(*) > 1
    ORDER BY opening
;

\echo duplicated var1 ...
    SELECT
        COUNT(*)
        , opening
        , var1
        , halfmoves 
    FROM scid_eco
    WHERE var2 IS NULL 
    GROUP BY opening, var1, halfmoves 
    HAVING COUNT(*) > 1
    ORDER BY opening, var1
;

\echo duplicate fen ...
SELECT * FROM (SELECT COUNT(*), fen FROM scid_eco GROUP BY fen ORDER BY COUNT DESC)t NATURAL JOIN opening WHERE COUNT > 1 ORDER BY fen;/*}}}*/

\echo duplicate main lines
SELECT COUNT(*), opening FROM v_opening GROUP BY opening HAVING COUNT(*) > 1;

\echo incorrect varations
SELECT * 
FROM 
(
    SELECT opening, var1, var2, var3, var4, var5, moves
    , LAG(moves) OVER 
    (
        PARTITION BY opening, var1, var2, var3, var4, var5 
        ORDER BY opening, var1, var2, var3, var4, var5, halfmoves
    ) FROM opening ORDER BY opening, var1, var2, var3, halfmoves
)t 
WHERE moves LIKE LAG||'%' = FALSE;

\echo missing positions
SELECT 
    halfmoves, LEAD, eco, opening, moves, var1, var2, var3, var4
FROM (
    SELECT halfmoves, 
        Lag(halfmoves) over (PARTITION BY opening, var1, var2, var3, var4, var5 ORDER BY opening, var1, var2, var3, var4, var5, halfmoves) as lead
        , eco, opening, var1, var2, var3, var4, var5, moves
    FROM opening ORDER BY opening, var1, var2, var3, var4, var5, halfmoves
)t where lead is not null and halfmoves-lead>1;

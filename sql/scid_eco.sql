
\set ON_ERROR_STOP on

drop table if exists opening cascade;
CREATE TABLE opening(
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

\copy opening (eco, opening, var1, var2, var3, var4, var5, fen, moves, halfmoves) from 'data/eco.dump';

ALTER TABLE game ADD COLUMN IF NOT EXISTS openingid INT;

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
* views
**************************************************/
/*{{{*/

DROP VIEW IF EXISTS v_game_opening;
CREATE VIEW v_game_opening AS
SELECT 
      P.site
    , openingid
    , opening
    , var1
    , var2
    , var3
FROM
(
        SELECT
          P.site
        , MAX(halfmove(p.fen))
        FROM POSITION P
        RIGHT JOIN opening eco
        ON eco.fen = P.fen
        GROUP BY site
) T
JOIN position P
    ON P.site=t.site
    AND halfmove(P.fen)=MAX
NATURAL JOIN opening
;

UPDATE game 
    SET openingid = G.openingid
    FROM v_game_opening G
    WHERE G.site = game.site
;

DROP VIEW IF EXISTS v_opening;
CREATE VIEW v_opening AS
SELECT 
      o.eco
    , o.opening
    , NULL::TEXT AS var1
    , NULL::TEXT AS var2
    , NULL::TEXT AS var3
    , NULL::TEXT AS var4
    , NULL::TEXT AS var5
    , MIN AS halfmoves
    , o.fen
    , o.moves 
    FROM
(
    SELECT
          opening
        , MIN(halfmoves)
    FROM opening AS eco
    WHERE var1 IS NULL
    GROUP BY opening
) T
JOIN opening o
ON o.opening = T.opening
AND var1 IS NULL
AND halfmoves = MIN
ORDER BY opening
;
GRANT SELECT ON v_opening to :user;

DROP VIEW IF EXISTS v_opening_var1;
CREATE VIEW v_opening_var1 AS
SELECT 
      e.eco
    , T.opening
    , T.var1 var1
    , NULL::TEXT AS var2
    , NULL::TEXT AS var3
    , NULL::TEXT AS var4
    , NULL::TEXT AS var5
    , e.halfmoves
    , e.fen
    , e.moves 
FROM 
(
    SELECT  
          opening
        , var1
        , MIN(halfmoves) 
    FROM opening
    WHERE (var1 !~ '^[1-9].' OR var1 IS NULL) 
    AND var2 IS NULL 
    GROUP BY  opening, var1 
) t 
JOIN opening AS e
    ON e.opening=t.opening 
    AND (e.var1=t.var1 OR T.var1 IS NULL) 
    AND e.halfmoves=t.MIN 

--ORDER BY opening, halfmoves, moves, var1 NULLS FIRST
ORDER BY opening, var1 NULLS FIRST
;
GRANT SELECT ON v_opening_var1 to :user;

DROP VIEW IF EXISTS v_opening_var2;
CREATE VIEW v_opening_var2 AS
SELECT 
      e.eco
    , T.opening
    , T.var1
    , T.var2
    , NULL::TEXT AS var3
    , NULL::TEXT AS var4
    , NULL::TEXT AS var5
    , e.halfmoves
    , e.fen
    , e.moves 
FROM 
(
    SELECT  
          opening
        , var1
        , var2
        , MIN(halfmoves) 
    FROM opening
    WHERE (var1 !~ '^[1-9].' OR var1 IS NULL) 
    AND (var2 !~ '^[1-9].' OR var2 IS NULL) 
    AND var3 IS NULL 
    GROUP BY  opening, var1, var2
) t 
JOIN opening AS e
    ON e.opening=t.opening 
    AND (e.var1=t.var1 OR T.var1 IS NULL) 
    AND (e.var2=t.var2 OR T.var2 IS NULL) 
    AND e.halfmoves=t.MIN 

ORDER BY 
    --opening, halfmoves, moves , var1 NULLS FIRST, var2 NULLS FIRST
    opening, var1 NULLS FIRST, var2 NULLS FIRST
;
GRANT SELECT ON v_opening_var2 to :user;

/*}}}*/
/**************************************************
* checks
**************************************************/
/*{{{*/
\echo duplicated openings ...
    SELECT
        COUNT(*)
        , opening
        , halfmoves 
    FROM opening
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
    FROM opening
    WHERE var2 IS NULL 
    GROUP BY opening, var1, halfmoves 
    HAVING COUNT(*) > 1
    ORDER BY opening, var1
;

\echo duplicate fen ...
SELECT * FROM (SELECT COUNT(*), fen FROM opening GROUP BY fen ORDER BY COUNT DESC)t NATURAL JOIN opening WHERE COUNT > 1 ORDER BY fen;/*}}}*/

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

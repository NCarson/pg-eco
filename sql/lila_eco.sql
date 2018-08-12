
\set ON_ERROR_STOP on


CREATE OR REPLACE FUNCTION  opid1(INT) 
RETURNS INT AS
$$
    SELECT e.openingid
    FROM (SELECT * FROM lila_eco WHERE openingid = $1)t 
    JOIN lila_eco e 
    ON e.NAME=t.NAME 
    AND e.var1 IS NULL
    ORDER BY e.halfmoves
    LIMIT 1
$$
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION  opid2(INT)
RETURNS INT AS
$$
    SELECT e.openingid
    FROM (SELECT * FROM lila_eco WHERE openingid = $1)t 
    JOIN lila_eco e 
    ON e.NAME=t.NAME AND e.var1=t.var1  AND e.var2 IS NULL
    ORDER BY e.halfmoves
    LIMIT 1
$$
LANGUAGE SQL;

UPDATE lila_eco SET opid1 = opid1(openingid);
UPDATE lila_eco SET opid2 = opid2(openingid);

UPDATE lila_eco
    SET moves=n.moves , halfmoves=n.halfmoves
FROM niklasf_eco n
WHERE lila_eco.fen = n.fen
;

/*
DROP VIEW IF EXISTS v_opening_canonical;
CREATE VIEW v_opening_canonical AS
SELECT
    o.opening ,o.var1, o.var2, o.var3, o.var4, o.var5
    ,fen
FROM
(
    SELECT 
        opening ,var1, var2, var3, var4, var5
        ,MIN(halfmoves)
    FROM scid_eco
    GROUP BY opening ,var1, var2, var3, var4, var5
) T
JOIN scid_eco o
    ON  o.opening=T.opening
    AND o.var1 = T.var1
    AND o.var2 = T.var2
    AND o.var3 = T.var3
    AND o.var4 = T.var4
    AND o.var5 = T.var5
    AND o.halfmoves = T.MIN
;

DROP VIEW IF EXISTS v_scid_missing;
CREATE VIEW v_scid_missing AS
SELECT
      t.NAME
    , t.var1
    , t.var2
    , t.var3
    , lila 
FROM 
(
    SELECT 
          o.fen scid
        , l.fen AS lila 
        , l.NAME
        , l.var1
        , l.var2
        , l.var3
    FROM scid_Eco o 
    RIGHT JOIN lila_eco l 
    ON moveless(l.fen)=clear_enpassant(moveless(o.fen))
) T WHERE scid IS NULL
;

DROP VIEW IF EXISTS v_lila_missing;
CREATE VIEW v_lila_missing AS
SELECT
      t.NAME
    , t.var1
    , t.var2
    , t.var3
    , scid
FROM 
(
    SELECT 
          o.fen scid
        , l.fen AS lila 
        , o.opening AS NAME
        , o.var1
        , o.var2
        , o.var3
    FROM scid_Eco o 
    LEFT JOIN lila_eco l 
    ON moveless(l.fen)=clear_enpassant(moveless(o.fen))
) T WHERE lila IS NULL
;

DROP VIEW IF EXISTS v_niklasf_missing;
CREATE VIEW v_niklasf_missing AS
SELECT
      t.NAME
    , niklasf
FROM 
(
    SELECT 
          o.fen niklasf
        , l.fen AS lila 
        , o.NAME
        , l.var1
        , l.var2
        , l.var3
    FROM niklasf_eco o 
    LEFT JOIN lila_eco l 
    ON moveless(l.fen)=clear_enpassant(moveless(o.fen))
) T WHERE lila IS NULL
;

DROP VIEW IF EXISTS v_scid_lila;
CREATE VIEW v_scid_lila AS
    SELECT 
        s.opening
            || ', ' || COALESCE(s.var1, '')
            || ', ' || COALESCE(s.var2, '')
            || ', ' || COALESCE(s.var3, '')
            || ', ' || COALESCE(s.var4, '')
            || ', ' || COALESCE(s.var5, '') AS scid
        ,l.name  
            || ', ' || COALESCE(l.var1, '')
            || ', ' || COALESCE(l.var2, '')
            || ', ' || COALESCE(l.var3, '') AS lila
    FROM scid_Eco s
    JOIN lila_eco l 
    ON moveless(l.fen)=clear_enpassant(moveless(s.fen))
;

DROP VIEW IF EXISTS v_niklasf_lila;
CREATE VIEW v_niklasf_lila AS
    SELECT 
        n.NAME AS niklasf
        ,l.name  
            || ', ' || COALESCE(l.var1, '')
            || ', ' || COALESCE(l.var2, '')
            || ', ' || COALESCE(l.var3, '') AS lila
    FROM niklasf_eco n
    JOIN lila_eco l 
    ON n.fen = l.fen
;
*/

/*
\echo lila COUNT
SELECT COUNT(*) FROM lila_eco;
\echo scid COUNT
SELECT COUNT(*) FROM opening;
\echo missing FROM lila
SELECT COUNT(*) FROM (SELECT o.fen scid, l.fen AS lila FROM opening o LEFT JOIN lila_eco l ON moveless(l.fen)=clear_enpassant(moveless(o.fen))) T WHERE lila IS NULL;
\echo missing FROM scid
SELECT COUNT(*) FROM (SELECT o.fen scid, l.fen AS lila FROM opening o RIGHT JOIN lila_eco l ON moveless(l.fen)=clear_enpassant(moveless(o.fen))) T WHERE scid IS NULL;
*/


\echo duplicate fen
SELECT COUNT, o.* 
FROM (SELECT COUNT(*), fen FROM lila_eco GROUP BY fen HAVING COUNT(*)>1)t 
JOIN lila_eco o ON o.fen=t.fen ORDER BY o.fen;

\echo duplicate NULL var1
SELECT 
    COUNT
    , l.* 
FROM (
    SELECT 
        COUNT(*)
        , meta
        , NAME 
        FROM lila_eco 
        WHERE var1 IS NULL 
        GROUP BY meta, NAME 
        HAVING COUNT(*)>1
)t 
JOIN lila_eco l 
    ON l.meta=t.meta 
    AND l.NAME=t.NAME 
    AND var1 IS NULL 
    ORDER BY l.eco, l.meta, l.NAME
;

\echo duplicate NULL var2
SELECT 
    COUNT
    , l.* 
FROM (
    SELECT 
        COUNT(*)
        , meta
        , NAME 
        , var1
        FROM lila_eco 
        WHERE var1 IS NOT NULL
        AND var2 IS NULL
        GROUP BY meta, NAME, var1
        HAVING COUNT(*)>1
)t 
JOIN lila_eco l 
    ON l.meta=t.meta 
    AND l.NAME=t.NAME 
    AND l.Var1=t.var1

WHERE 
    l.var1 IS NOT NULL
    AND var2 IS NULL
    ORDER BY l.meta, l.NAME, l.var1
;

\echo duplicate NULL var3
SELECT 
    COUNT
    , l.* 
FROM (
    SELECT 
        COUNT(*)
        , meta
        , NAME 
        , var1
        , var2
        FROM lila_eco 
        WHERE var1 IS NOT NULL
        AND var2 IS NOT NULL
        AND var3 IS NULL
        GROUP BY meta, NAME, var1, var2
        HAVING COUNT(*)>1
)t 
JOIN lila_eco l 
    ON l.meta=t.meta 
    AND l.NAME=t.NAME 
    AND l.Var1=t.var1
    AND l.Var2=t.var2

WHERE 
    l.var1 IS NOT NULL
    AND l.var2 IS not NULL
    AND l.var3 IS NULL
    ORDER BY l.meta, l.NAME, l.var1, l.var2
;

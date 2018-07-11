

\set ON_ERROR_STOP on

DROP TABLE IF EXISTS lila_eco CASCADE;
CREATE TABLE IF NOT EXISTS lila_eco (
    eco         VARCHAR(3)
    ,meta       TEXT
    ,NAME       TEXT
    ,var1       TEXT
    ,var2       TEXT
    ,var3       TEXT
    ,fen        board
);

\COPY lila_eco FROM 'data/lila_eco.dump'

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
    FROM opening
    GROUP BY opening ,var1, var2, var3, var4, var5
) T
JOIN opening o
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
    FROM opening o 
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
    FROM opening o 
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
    FROM opening s
    JOIN lila_eco l 
    ON moveless(l.fen)=clear_enpassant(moveless(s.fen))
;

\echo lila COUNT
SELECT COUNT(*) FROM lila_eco;
\echo scid COUNT
SELECT COUNT(*) FROM opening;
\echo missing FROM lila
SELECT COUNT(*) FROM (SELECT o.fen scid, l.fen AS lila FROM opening o LEFT JOIN lila_eco l ON moveless(l.fen)=clear_enpassant(moveless(o.fen))) T WHERE lila IS NULL;
\echo missing FROM scid
SELECT COUNT(*) FROM (SELECT o.fen scid, l.fen AS lila FROM opening o RIGHT JOIN lila_eco l ON moveless(l.fen)=clear_enpassant(moveless(o.fen))) T WHERE scid IS NULL;


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

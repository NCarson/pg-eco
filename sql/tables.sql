
\set ON_ERROR_STOP on


DROP TABLE IF EXISTS lila_eco CASCADE;
CREATE TABLE IF NOT EXISTS lila_eco (
     openingid  serial          NOT NULL
    ,eco        VARCHAR(3)      NOT NULL
    ,meta       TEXT            NOT NULL
    ,NAME       TEXT            NOT NULL
    ,var1       TEXT
    ,var2       TEXT
    ,var3       TEXT
    ,fen        board           NOT NULL
    ,moves      TEXT
    ,halfmoves  INT
);

\COPY lila_eco (eco, meta, NAME, var1, var2, var3, fen) FROM 'data/lila_eco.dump'

DROP TABLE IF EXISTS niklasf_eco CASCADE;
CREATE TABLE IF NOT EXISTS niklasf_eco (
     eco        VARCHAR(3)      NOT NULL
    ,NAME       TEXT            NOT NULL
    ,moves      TEXT
    ,halfmoves  INT
    ,fen        board           NOT NULL
);
\COPY niklasf_eco FROM 'data/niklasf_eco.dump'

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


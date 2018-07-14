
\set ON_ERROR_STOP 

CREATE OR REPLACE FUNCTION eco_name(NAME TEXT, var1 TEXT)
RETURNS TEXT AS $$
    select 
        CASE WHEN $2 IS NULL THEN $1
             ELSE COALESCE($1, '') || ': ' || COALESCE($2, '')
    END
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION eco_name(NAME TEXT, var1 TEXT, var2 TEXT)
RETURNS TEXT AS $$
    select 
        CASE WHEN $2 IS NULL THEN $1
             WHEN $3 IS NULL THEN  $1 || ': ' || $2
             ELSE $1 || ': ' || $2 || ', ' || $3
    END
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION eco_name(NAME TEXT, var1 TEXT, var2 TEXT, var3 TEXT)
RETURNS TEXT AS $$
    select 
        CASE WHEN $2 IS NULL THEN $1
             WHEN $3 IS NULL THEN  $1 || ': ' || $2
             WHEN $4 IS NULL THEN  $1 || ': ' || $2 ||  ', ' || $3
             ELSE $1 || ': ' || $2 || ', ' || $3 || ', ' || $4
    END
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION eco_root(NAME TEXT)
RETURNS TEXT AS $$
    select REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(replace($1
        , ' Defense', '')
        , ' Game', '')
        , ' Accepted', '')
        , ' Declined', '')
        , ' Attack', '')
        , ' Opening', '')
$$ LANGUAGE SQL IMMUTABLE STRICT;

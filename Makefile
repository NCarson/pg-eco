ifndef DB
	ifndef PGDATABASE
	$(error DB is not set and PGDATABASE is not set)
	endif 
	DB = $(PGDATABASE)
endif

PYTHON = python3
PSQL = psql -X -d$(DB)

all: lila_data lila scid_data scid

lila_data:
	$(PYTHON) script/parse_lila.py > data/lila_eco.dump

lila:
	$(PSQL) -f sql/lila_eco.sql -v user=$(USER) > lila.log

scid_data:
	$(PYTHON) script/parse_lila.py > data/lila_eco.dump

scid: 
	$(PSQL) -f sql/scid_eco.sql -v user=$(USER) > scid.log


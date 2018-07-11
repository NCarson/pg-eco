ifndef DB
	ifndef PGDATABASE
	$(error DB is not set and PGDATABASE is not set)
	endif 
	DB = $(PGDATABASE)
endif

PYTHON = python3
DATA_DIREC = './data/big/'
USER='"www-data"'
PSQL = psql -X -d$(DB)

eco:
	PAGER='' $(PSQL) -d$(DB) -f sql/eco.sql -v user=$(USER)

eco_data:
	python3 script/new_opening.py > data/eco.dump
	$(PSQL) -d$(DB) -f sql/eco.sql -v user=$(USER)

lila_eco:
	$(PYTHON) script/parse_lila.py > data/lila_eco.dump

scid_eco:
	$(PYTHON) script/parse_lila.py > data/lila_eco.dump


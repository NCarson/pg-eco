ifndef DB
	ifndef PGDATABASE
	$(error DB is not set and PGDATABASE is not set)
	endif 
	DB = $(PGDATABASE)
endif

PYTHON = python3
PSQL = psql -X -d$(DB)

all: data lila scid

.PHONY: data
data:
	$(PYTHON) script/parse_lila.py > data/lila_eco.dump
	$(PYTHON) script/parse_scid.py > data/scid_eco.dump
	$(PYTHON)  data/niklasf/eco.py > data/niklasf_eco.dump
	$(PSQL) -f sql/tables.sql
	$(PSQL) -f sql/views.sql

.PHONY: lila
lila:
	$(PSQL) -f sql/tables.sql
	$(PSQL) -f sql/views.sql
	$(PSQL) -f sql/lila_eco.sql > lila.log

.PHONY: scid
scid: lila
	$(PSQL) -f sql/scid_eco.sql -v user=$(USER) > scid.log



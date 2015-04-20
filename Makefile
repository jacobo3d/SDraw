all: figures.json
	coffee -c -b src/coffee/*.coffee

figures.json: figures.coffee
	coffee src/scripts/figures.coffee | jq . > src/data/figures.json
#	ruby figures | jq . > figures.json
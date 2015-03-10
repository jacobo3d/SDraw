all:
	coffee -c -b *.coffee

figures.json: figures.coffee
	coffee figures.coffee | jq . > figures.json
#	ruby figures | jq . > figures.json


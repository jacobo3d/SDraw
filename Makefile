all:
	coffee -c -b *.coffee

figures.json:
	coffee figures.json | jq . > figures.json
#	ruby figures | jq . > figures.json


all:
	coffee -c -b *.coffee

figures.json:
	ruby figures | jq . > figures.json


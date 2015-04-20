all: figures.json
	coffee -c -b *.coffee

figures.json: figures.coffee
	coffee figures.coffee | jq . > figures.json
#	ruby figures | jq . > figures.json

build:
	cp index.html ../www/
	cp -R js ../www/
	cp -R css ../www/
	cp -R images ../www
	cp -R data ../www
	cp -R kanji ../www

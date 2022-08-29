test:
ifeq ($(g),)
	node_modules/.bin/mocha --colors --check-leaks --require kaoscript/register --reporter spec "test/*.test.ks"
else
	node_modules/.bin/mocha --colors --check-leaks --require kaoscript/register --reporter spec -g "$(g)" "test/*.test.ks"
endif

coverage:
ifeq ($(g),)
	./node_modules/@zokugun/istanbul.cover/src/cli.js
else
	./node_modules/@zokugun/istanbul.cover/src/cli.js "$(g)"
endif

sync:
	./scripts/sync.ks

clean:
	npx kaoscript --clean

cls:
	printf '\033[2J\033[3J\033[1;1H'

update:
	@make clean
	rm -rf node_modules package-lock.json
	nrm use local
	npm i

local:
	nrm use local
	npm unpublish @kaoscript/source-generator --force
	npm publish

dev: export DEBUG = 1
dev:
	@# clear terminal
	@make cls

	@# tests
	npx kaoscript test/generate.dev.ks "generate "

.PHONY: test coverage sync

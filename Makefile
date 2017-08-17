test:
ifeq ($(g),)
	node_modules/.bin/mocha --colors --check-leaks --compilers ks:kaoscript/register --reporter spec
else
	node_modules/.bin/mocha --colors --check-leaks --compilers ks:kaoscript/register --reporter spec -g "$(g)"
endif

clean:
	find -L . -type f \( -name "*.ksb" -o -name "*.ksh" -o -name "*.ksm" \) -exec rm {} \;

.PHONY: test
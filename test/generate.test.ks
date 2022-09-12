#![bin]
#![error(off)]

extern {
	__dirname: String
	console
	JSON
	process

	func describe(...)
	func it(...)
}

import {
	'..'				for generate
	'@kaoscript/parser'	for parse
	'chai'				for expect
	'fs'
	'klaw-sync'			=> klaw
	'path'
}

var debug = process.env.DEBUG == '1' || process.env.DEBUG == 'true' || process.env.DEBUG == 'on'
var mut testings = []

if process.argv[2].endsWith('test/parse.dev.ks') && process.argv.length > 3 {
	var args = process.argv[3].split(' ')

	if args[0] == 'parse' {
		if !args[1].includes('|') && !args[1].includes('[') {
			testings = args.slice(1)
		}
		else {
			testings = args
		}
	}
}

func prepare(file) { # {{{
	var root = path.dirname(file)
	var name = path.basename(file).slice(0, -5)

	if testings.length > 0 && !testings.some((testing, ...) => name.startsWith(testing) || testing.startsWith(name)) {
		return
	}

	it(name, () => {
		var json = fs.readFileSync(file, {
			encoding: 'utf8'
		})

		var data = generate(JSON.parse(json, (key, value) => value == 'Infinity' ? Infinity : value))

		var source = fs.readFileSync(path.join(root, name + '.ks'), {
			encoding: 'utf8'
		})

		try {
			expect(data).to.eql(source)
		}
		catch ex {
			if debug {
				console.log(data)
			}

			throw ex
		}
	})
} # }}}

describe('generate', () => {
	var options = {
		nodir: true
		traverseAll: true
		filter: item => item.path.slice(-5) == '.json'
	}

	for file in klaw(path.join(__dirname, 'fixtures'), options) {
		prepare(file.path)
	}
})

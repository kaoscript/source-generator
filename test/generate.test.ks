#![bin]
#![error(off)]

extern {
	__dirname: String
	JSON
	process

	func describe(...)
	func it(...)
}

import {
	'node:fs'
	'node:path'
	'npm:chai'				for expect
	'npm:klaw-sync'			=> klaw
	'..'					for generate, NodeData
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
		var content = fs.readFileSync(file, {
			encoding: 'utf8'
		})

		var node = JSON.parse(content, (key, value) => if value == 'Infinity' set Infinity else value):>(NodeData)

		expect(node).to.exist

		var data = generate(node)

		var source = fs.readFileSync(path.join(root, name + '.ks'), {
			encoding: 'utf8'
		})

		try {
			expect(data).to.eql(source)
		}
		catch ex {
			if debug {
				echo(data)
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

	for var file in klaw(path.join(__dirname, 'fixtures'), options) {
		prepare(file.path)
	}
})

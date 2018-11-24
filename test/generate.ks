#![bin]

extern {
	__dirname: String
	console
	describe: Function
	it: Function
	JSON
}

import {
	'..'		for generate
	'chai'		for expect
	'fs'
	'klaw-sync'	=> klaw
	'path'
}

describe('generate', func() {
	func prepare(file) {
		const root = path.dirname(file)
		const name = path.basename(file).slice(0, -5)

		it(name, func() {
			const json = fs.readFileSync(file, {
				encoding: 'utf8'
			})

			const data = generate(JSON.parse(json, (key, value) => value == 'Infinity' ? Infinity : value))
			console.log(data)

			const source = fs.readFileSync(path.join(root, name + '.ks'), {
				encoding: 'utf8'
			})

			expect(data).to.eql(source)
		})
	}

	const options = {
		nodir: true
		traverseAll: true
		filter: item => item.path.slice(-5) == '.json'
	}

	for file in klaw(path.join(__dirname, 'fixtures'), options) {
		prepare(file.path)
	}
})
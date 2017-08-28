#![bin]

extern {
	__dirname: String
	console
	describe: Function
	it: Function
	JSON
}

import {
	'..'	for generate
	'chai'	for expect
	'fs'
	'path'
}

describe('generate', func() {
	func prepare(file) {
		const name = file.slice(0, -5)
		
		it(name, func() {
			const json = fs.readFileSync(path.join(__dirname, 'fixtures', file), {
				encoding: 'utf8'
			})
			
			const data = generate(JSON.parse(json, (key, value) => {
				if value == 'Infinity' {
					return Infinity
				}
				
				return value
			}))
			//console.log(data)
			
			const source = fs.readFileSync(path.join(__dirname, 'fixtures', name + '.ks'), {
				encoding: 'utf8'
			})
			
			expect(data).to.eql(source)
		})
	}
	
	for file in fs.readdirSync(path.join(__dirname, 'fixtures')) when file.slice(-5) == '.json' {
		prepare(file)
	}
})
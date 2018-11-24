#![bin]

import 'fs'
import 'klaw-sync' => klaw
import 'path'

extern __dirname, console

const srcRoot = path.join(__dirname, '..', 'parser', 'test', 'fixtures')
const destRoot = path.join(__dirname, 'test', 'fixtures')

const files = []

// 1. update existing files
for file in klaw(srcRoot, {
	nodir: true,
	traverseAll: true,
	filter: item => item.path.slice(-5) == '.json'
}) {
	update(file.path)
}

func update(srcPath) { // {{{
	const dirname = path.basename(path.dirname(srcPath).substr(srcRoot.length))
	const filename = path.basename(srcPath)

	files[`\(path.join(dirname, filename))`] = true

	try {
		fs.readFileSync(path.join(destRoot, dirname, filename), {
			encoding: 'utf8'
		})

		write(dirname, filename, filename)
	}
	catch {
		try {
			fs.readFileSync(path.join(destRoot, dirname, filename + '.no'), {
				encoding: 'utf8'
			})

			console.log(`--> \(path.join(dirname, filename)).no`)

			write(dirname, filename, `\(filename).no`)
		}
		catch {
			write(dirname, filename, filename)
		}
	}
} // }}}

func write(dirname, srcFilename, destFilename) { // {{{
	const data = fs.readFileSync(path.join(srcRoot, dirname, srcFilename), {
		encoding: 'utf8'
	})

	fs.writeFileSync(path.join(destRoot, dirname, destFilename), data, {
		encoding: 'utf8'
	})
} // }}}

// 2. remove old files
for file in klaw(destRoot, {
	nodir: true,
	traverseAll: true,
	filter: item => item.path.slice(-3) == '.ks'
}) {
	check(file.path)
}

func check(destPath) { // {{{
	const dirname = path.basename(path.dirname(destPath).substr(destRoot.length))
	const filename = path.basename(destPath)

	try {
		fs.readFileSync(path.join(srcRoot, dirname, filename), {
			encoding: 'utf8'
		})
	}
	catch {
		// delete

		console.log(`deleting \(path.join(dirname, filename.slice(-3))).json`)

		fs.unlinkSync(path.join(destPath, dirname, `\(filename.slice(-3)).json`))
		fs.unlinkSync(path.join(destPath, dirname, filename))
	}
} // }}}
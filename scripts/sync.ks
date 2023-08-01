#!/usr/bin/env kaoscript

import {
	'node:path'
	'npm:fs-extra' => fse
	'npm:klaw-sync' => klaw
}

extern __dirname, console

var srcRoot = path.join(__dirname, '..', '..', 'parser', 'test', 'fixtures')
var destRoot = path.join(__dirname, '..', 'test', 'fixtures')

// 1. update existing files
func update(srcPath) { # {{{
	return unless fse.pathExistsSync(srcPath.slice(0, -5) + '.ks')

	var dirname = path.basename(path.dirname(srcPath).substr(srcRoot.length))
	var filename = path.basename(srcPath)

	try {
		fse.readFileSync(path.join(destRoot, dirname, filename), {
			encoding: 'utf8'
		})

		write(dirname, filename, filename)
	}
	catch {
		try {
			fse.readFileSync(path.join(destRoot, dirname, filename + '.no'), {
				encoding: 'utf8'
			})

			console.log(`- no: \(path.join(dirname, filename))`)

			write(dirname, filename, `\(filename).no`)
		}
		catch {
			console.log(`- new: \(path.join(dirname, filename))`)

			write(dirname, filename, filename)

			var ksfile = `\(filename.slice(0, -5)).ks`

			write(dirname, ksfile, ksfile)
		}
	}
} # }}}

func write(dirname, srcFilename, destFilename) { # {{{
	var data = fse.readFileSync(path.join(srcRoot, dirname, srcFilename), {
		encoding: 'utf8'
	})

	fse.outputFileSync(path.join(destRoot, dirname, destFilename), data, {
		encoding: 'utf8'
	})
} # }}}

for var file in klaw(srcRoot, {
	nodir: true,
	traverseAll: true,
	filter: item => item.path.slice(-5) == '.json'
}) {
	update(file.path)
}

// 2. remove old files
func check(destPath) { # {{{
	var dirname = path.basename(path.dirname(destPath).substr(destRoot.length))
	var filename = path.basename(destPath)

	try {
		fse.readFileSync(path.join(srcRoot, dirname, filename.slice(0, -3) + '.json'), {
			encoding: 'utf8'
		})
	}
	catch {
		// delete
		console.log(`- deleting: \(path.join(dirname, filename.slice(0, -3))).ks`)

		fse.removeSync(path.join(destRoot, dirname, filename))
		fse.removeSync(path.join(destRoot, dirname, `\(filename.slice(0, -3)).json`))
		fse.removeSync(path.join(destRoot, dirname, `\(filename.slice(0, -3)).error`))
	}
} # }}}

for var file in klaw(destRoot, {
	nodir: true,
	traverseAll: true,
	filter: item => item.path.slice(-3) == '.ks'
}) {
	check(file.path)
}

var fs = require('fs');
var path = require('path');

var files = fs.readdirSync(path.join(__dirname, '..', 'parser', 'test', 'fixtures'));

var file;
for(var i = 0; i < files.length; i++) {
	file = files[i];

	if(file.slice(-5) === '.json') {
		sync(file);
	}
}

function sync(file) {
	try {
		fs.readFileSync(path.join(__dirname, 'test', 'fixtures', file), {
			encoding: 'utf8'
		});

		write(file, file)
	}
	catch(error) {
		try {
			fs.readFileSync(path.join(__dirname, 'test', 'fixtures', file + '.no'), {
				encoding: 'utf8'
			});

			write(file, file + '.no')
		}
		catch(error) {
			console.log(file)
		}
	}
}

function write(source, target) {
	//console.log(source, target)
	var data = fs.readFileSync(path.join(__dirname, '..', 'parser', 'test', 'fixtures', source), {
		encoding: 'utf8'
	});

	fs.writeFileSync(path.join(__dirname, 'test', 'fixtures', target), data, {
		encoding: 'utf8'
	});
}
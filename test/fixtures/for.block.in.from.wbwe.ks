extern console: {
	log(...args)
}

heroes = ['leto', 'duncan', 'goku']

for hero, index in heroes from 2 to 5 {
	console.log('The hero at index %d is %s', index, hero)
}
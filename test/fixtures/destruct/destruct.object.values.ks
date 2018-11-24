let {foo = 3} = {
	foo: 2
}
console.log(foo)
let {foo = 3} = {
	foo: undefined
}
console.log(foo)
let {foo = 3} = {
	bar: 2
}
console.log(foo)
var dyn {foo = 3} = {
	foo: 2
}
console.log(foo)
var dyn {foo = 3} = {
	foo: undefined
}
console.log(foo)
var dyn {foo = 3} = {
	bar: 2
}
console.log(foo)
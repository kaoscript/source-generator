let foo = {
	bar: "hello"
	baz: 3
}
let {bar: a = "bar", baz: b = "baz"} = foo
console.log(a)
console.log(b)
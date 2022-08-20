extern console
func foo(item: any?) {
	console.log(item)
}
func bar(item = null) {
	console.log(item)
}
func baz(item: String?) {
	console.log(item)
}
func qux(item: String? = null) {
	console.log(item)
}
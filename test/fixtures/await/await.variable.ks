async func foo(bar: string, qux: int): string {
	return bar + "+" + qux
}
func bar(callback) {
	let text = await foo("foobar", 42)
	callback(null, text)
}
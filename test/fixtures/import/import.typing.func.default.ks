import "foobar" {
	func foo(...) => f1
	async func bar() => b1
	func baz(value: Number): Number => b2
	func baz(value: String): String
	async func qux(value: Number): Number => q1
	async func qux(value: String): String
}
import "barfoo" {
	func foo(...) => f1
	async func bar() => b1
	func baz(value: Number): Number => b2
	func baz(value: String): String
	async func qux(value: Number): Number => q1
	async func qux(value: String): String
}
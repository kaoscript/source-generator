import "foobar" {
	func foo(...)
	async func bar()
	func baz(value: Number): Number
	func baz(value: String): String
	async func qux(value: Number): Number
	async func qux(value: String): String
} => {foo: f1, bar: b1, baz: b2, qux: q1}
import "barfoo" {
	func foo(...)
	async func bar()
	func baz(value: Number): Number
	func baz(value: String): String
	async func qux(value: Number): Number
	async func qux(value: String): String
} => {foo: f1, bar: b1, baz: b2, qux: q1}
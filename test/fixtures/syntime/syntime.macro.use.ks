syntime macro using_a(a: Identifier, e: Expression) {
	quote {
		(() => {
		var dyn #(a) = 42
		return #(e)
		})()
	}
}
var dyn four = using_a(a, a / 10)
enum Color {
	Red
	Green
	Blue
}
func foobar(red) {
	var x: Color? = if red {
		set .Red
	}
	else {
		set null
	}
}
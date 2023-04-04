class Foobar {
	private @x: Number
	private @y: Number
	constructor(fn) {
		fn((values) => {
			{@x, @y} = values
		})
	}
}
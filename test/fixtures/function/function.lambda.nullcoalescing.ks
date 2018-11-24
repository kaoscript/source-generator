func foo(x: Number, y: Number, z: any?) {
	z ??= (z: Number) => [x, y, z]
	return z
}
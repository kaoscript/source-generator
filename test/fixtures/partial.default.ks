class Shape {
	private {
		_color: string = ''
	}
	
	Shape(@color)
}

impl Shape {
	draw(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}
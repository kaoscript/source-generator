class Shape {
	private _color: string = ""
	private _type: string = ""
	static makeRectangle(color: string): Shape => Shape.new("rectangle", color)
	constructor(@type, @color)
}
var r = Shape.makeRectangle("black")
expect(r.type).to.equal("rectangle")
expect(r.color).to.equal("black")
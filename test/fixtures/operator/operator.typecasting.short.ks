func foobar(p: Point) {
	var d3 = (p as Point3D)
}
func quxbaz(p: Point) {
	var d3 = (p as! Point3D)
}
func corge(p: Point) {
	var d3 = (p as? Point3D)
}
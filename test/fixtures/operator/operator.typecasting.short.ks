func foobar(p: Point) {
	const d3 = (p as Point3D)
}
func quxbaz(p: Point) {
	const d3 = (p as! Point3D)
}
func corge(p: Point) {
	const d3 = (p as? Point3D)
}
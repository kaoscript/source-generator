try {
	console.log("foobar")
}
on RangeError catch error {
	console.log("RangeError", error)
}
catch error {
	console.log("Error", error)
}
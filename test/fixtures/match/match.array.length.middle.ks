var dyn v = [1, 2, 3, 4, 5]
match v {
	with [first, ...middle, last] => console.log(first, middle, last)
	else => console.log("empty")
}
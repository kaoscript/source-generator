var dyn v = [1, 2, 3]
match v {
	with [first, ...] => console.log(first)
	with [..., last] => console.log(last)
	else => console.log("empty")
}
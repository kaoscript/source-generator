let v = [1, 2, 3]
switch v {
	with [first, ...] => console.log(first)
	with [..., last] => console.log(last)
	=> console.log("empty")
}
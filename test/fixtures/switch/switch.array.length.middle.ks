var dyn v = [1, 2, 3, 4, 5]
switch v {
	with [first, ...middle, last] => console.log(first, middle, last)
	=> console.log("empty")
}
let v = [1, 2, 3, 4, 5]
switch v {
	[] => console.log("empty")
	with [elem] => console.log(elem)
	with [, , ...rest] => console.log(rest)
}
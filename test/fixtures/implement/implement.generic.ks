import "@oz/lang"
var a: Array<number> = [1, 3, 2, 4]
console.log(a)
impl Array {
	sort(): Array<number> => (this as Array).sort((a, b) => a - b)
}
console.log(a.sort())
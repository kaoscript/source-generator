extern console
func min() => ["female", 24]
namespace foo {
	var [gender, age] = min()
}
console.log(foo.age)
console.log(`\(foo.gender)`)
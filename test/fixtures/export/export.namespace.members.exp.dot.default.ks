namespace NS {
	export func foo() {
	}
	export func bar() {
	}
	export func qux() {
	}
}
export {
	NS.foo => foo
	NS.bar => bar
	NS.qux => qux
}
class URI {
	syntime do {
		var ast = register("file", "[ \"//\" [ host ] ] path_absolute")
		echo(ast)
		quote ast
	}
}
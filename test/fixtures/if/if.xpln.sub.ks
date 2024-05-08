var dyn text = if foo && bar {
	set if qux || corge {
		set "a"
	}
	else {
		set "b"
	}
}
else {
	set if grault + garply {
		set "c"
	}
	else {
		set if waldo {
			set "d"
		}
		else {
			set "e"
		}
	}
}
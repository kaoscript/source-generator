enum ANSIColor {
	black
	red
	green
	yellow
	blue
	magenta
	cyan
	white
	default
}
func color(fg: ANSIColor, bg: ANSIColor): String {
	let fg_code = switch fg {
		black => 30
		red => 31
		green => 32
		yellow => 33
		blue => 34
		magenta => 35
		cyan => 36
		white => 37
		default => 39
	}
	let bg_code = switch bg {
		black => 40
		red => 41
		green => 42
		yellow => 44
		blue => 44
		magenta => 45
		cyan => 46
		white => 47
		default => 49
	}
	return `\(fg_code);\(bg_code)m`
}
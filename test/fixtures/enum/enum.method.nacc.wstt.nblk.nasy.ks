enum Weekday {
	MONDAY
	TUESDAY
	WEDNESDAY
	THURSDAY
	FRIDAY
	SATURDAY
	SUNDAY
	static fromString(value: String): Weekday? {
		match value {
			"monday" => return MONDAY
		}
		return null
	}
}
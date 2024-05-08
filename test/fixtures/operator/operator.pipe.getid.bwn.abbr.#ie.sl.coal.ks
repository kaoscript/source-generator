extern func parseInt(value: String): Number
func getSupervisorId(enteredId: String?): Number? {
	return (if Number.isFinite(_) {
		set _
	}
	else {
		set null
	} <| parseInt ?<| enteredId) ?? 0
}
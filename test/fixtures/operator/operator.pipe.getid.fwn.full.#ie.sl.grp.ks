extern func parseInt(value: String): Number
func getSupervisorId(enteredId: String?): Number {
	return (enteredId |>? parseInt(_)) |> if Number.isFinite(_) {
		set _
	}
	else {
		set 0
	}
}
extern func parseInt(value: String): Number
func getSupervisorId(enteredId: String?): Number {
	return ((enteredId |>? parseInt(_)) |> if(Number.isFinite(_), _, null)) ?? 0
}
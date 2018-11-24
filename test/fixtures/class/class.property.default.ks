class Vector {
	public x: Number {
		get
		set
	}
	public y: Number {
		get
		set => Math.abs(y)
	}
	public z: Number {
		get => 0
	}
}
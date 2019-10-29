extension String {
	var trimmed: String {
		trimmingCharacters(in: .whitespaces)
	}
	
	var isTrimmedEmpty: Bool {
		trimmed.isEmpty
	}
}

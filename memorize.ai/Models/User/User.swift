struct User: Identifiable, Equatable {
	let id: String
	var name: String
	var email: String
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}
}

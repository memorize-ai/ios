final class User: Identifiable, Equatable {
	let id: String
	var name: String
	
	init(id: String, name: String) {
		self.id = id
		self.name = name
	}
	
	static func == (lhs: User, rhs: User) -> Bool {
		lhs.id == rhs.id
	}
}

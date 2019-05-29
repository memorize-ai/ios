class Permission {
	let id: String
	var role: Role
	
	init(id: String, role: Role) {
		self.id = id
		self.role = role
	}
}

enum Role: String {
	case none = "none"
	case viewer = "viewer"
	case editor = "editor"
	case admin = "admin"
	
	init(_ string: String) {
		switch string {
		case "viewer":
			self = .viewer
		case "editor":
			self = .editor
		case "admin":
			self = .admin
		default:
			self = .none
		}
	}
}

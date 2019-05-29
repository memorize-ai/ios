import Foundation

class Permission {
	let id: String
	var role: Role
	let date: Date
	var confirmed: Date?
	var status: PermissionStatus
	let sender: String
	
	init(id: String, role: Role, date: Date, confirmed: Date?, status: PermissionStatus, sender: String) {
		self.id = id
		self.role = role
		self.date = date
		self.confirmed = confirmed
		self.status = status
		self.sender = sender
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

enum PermissionStatus: Int {
	case declined = -1
	case pending = 0
	case accepted = 1
	
	init(_ number: Int) {
		switch number {
		case -1:
			self = .declined
		case 1:
			self = .accepted
		default:
			self = .pending
		}
	}
}

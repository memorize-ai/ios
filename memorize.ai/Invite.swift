import Foundation

var invites = [Invite]()

class Invite {
	let id: String
	var role: Role
	let date: Date
	var confirmed: Date?
	var status: InviteStatus
	let sender: String
	
	init(id: String, role: Role, date: Date, confirmed: Date?, status: InviteStatus, sender: String) {
		self.id = id
		self.role = role
		self.date = date
		self.confirmed = confirmed
		self.status = status
		self.sender = sender
	}
}

enum InviteStatus: Int {
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

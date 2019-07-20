import Firebase

class ReputationValue {
	let id: String
	var amount: Int
	var order: Int
	
	init(id: String, amount: Int, order: Int) {
		self.id = id
		self.amount = amount
		self.order = order
	}
	
	convenience init(_ snapshot: DocumentSnapshot) {
		self.init(
			id: snapshot.documentID,
			amount: snapshot.get("amount") as? Int ?? 0,
			order: snapshot.get("order") as? Int ?? 0
		)
	}
}

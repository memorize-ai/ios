import FirebaseFirestore

extension DocumentSnapshot {
	func getDate(_ field: String) -> Date? {
		(get(field) as? Timestamp)?.dateValue()
	}
}

import FirebaseFirestore

extension FirestoreErrorCode {
	init?(error: Error) {
		self.init(rawValue: error._code)
	}
}

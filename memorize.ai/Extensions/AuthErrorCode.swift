import FirebaseAuth

extension AuthErrorCode {
	init?(error: Error) {
		self.init(rawValue: error._code)
	}
}

import Combine

final class ForgotPasswordViewModel: ObservableObject {
	@Published var email: String
	
	init(email: String = "") {
		self.email = email
	}
	
	var isResetButtonDisabled: Bool {
		email.isEmpty
	}
}

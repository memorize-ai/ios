import Combine

final class ForgotPasswordViewModel: ObservableObject {
	@Published var email: String
	@Published var loadingState = LoadingState.none
	
	init(email: String = "") {
		self.email = email
	}
	
	var isResetButtonDisabled: Bool {
		email.isEmpty
	}
	
	func sendResetEmail() {
		
	}
}

import Combine

final class SignUpViewModel: ViewModel {
	@Published var name = ""
	@Published var email = ""
	@Published var password = ""
	
	@Published var shouldShowNameRedBorder = false
	@Published var shouldShowEmailRedBorder = false
	@Published var shouldShowPasswordRedBorder = false
	
	@Published var loadingState = LoadingState.none
	
	var isSignUpButtonDisabled: Bool {
		name.isEmpty || email.isEmpty || password.isEmpty
	}
	
	func signUp() {
		// TODO: Sign up
	}
}

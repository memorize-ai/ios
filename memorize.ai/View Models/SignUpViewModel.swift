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
		name.isTrimmedEmpty ||
		email.isTrimmedEmpty ||
		password.isTrimmedEmpty
	}
	
	func signUp() {
		// TODO: Sign up
	}
}

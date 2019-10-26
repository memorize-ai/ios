import Combine
import FirebaseAuth

final class ForgotPasswordViewModel: ObservableObject {
	static let unknownErrorTitle = "Unknown error"
	static let unknownErrorDescription = "Sorry about that! Please try again"
	
	@Published var email: String {
		didSet {
			guard loadingState.didFail else { return }
			shouldShowEmailRedBorder = false
		}
	}
	@Published var loadingState = LoadingState.none
	@Published var shouldShowEmailRedBorder = false
	@Published var shouldShowErrorModal = false
	
	var errorModal: (title: String, description: String)?
	
	init(email: String = "") {
		self.email = email
	}
	
	var isResetButtonDisabled: Bool {
		email.isEmpty
	}
	
	func sendResetEmail() {
		loadingState = .loading()
		shouldShowEmailRedBorder = false
		auth.sendPasswordReset(withEmail: email).done {
			self.loadingState = .success()
		}.catch(failPasswordReset)
	}
	
	func failPasswordReset(error: Error) {
		loadingState = .failure(message: error.localizedDescription)
		handleError(code: AuthErrorCode(error: error))
	}
	
	func applyError(
		title: String,
		description: String,
		invalidEmail: Bool
	) {
		errorModal = (title, description)
		shouldShowEmailRedBorder = invalidEmail
		shouldShowErrorModal = true
	}
	
	func handleError(code: AuthErrorCode?) {
		switch code {
		case .invalidEmail:
			applyError(
				title: "Invalid email",
				description: "Your email should be of the form xyz@xyz.xyz",
				invalidEmail: true
			)
		case .networkError:
			applyError(
				title: "Network error",
				description: "There was a problem connecting to our servers. Please try again",
				invalidEmail: false
			)
		case .userNotFound:
			applyError(
				title: "Email not found",
				description: "There is no user with the email \(email). Would you like to sign up instead?",
				invalidEmail: true
			)
		default:
			applyError(
				title: Self.unknownErrorTitle,
				description: Self.unknownErrorDescription,
				invalidEmail: false
			)
		}
	}
}

import Combine
import FirebaseAuth
import LoadingState

final class ForgotPasswordViewModel: ViewModel {
	static let unknownErrorTitle = "Unknown error"
	static let unknownErrorDescription = "Sorry about that! Please try again"
	
	@Published var email: String {
		didSet {
			guard loadingState.didFail else { return }
			shouldShowEmailRedBorder = false
		}
	}
	
	@Published var shouldShowEmailRedBorder = false
	
	@Published var loadingState = LoadingState()
	@Published var shouldShowErrorModal = false
	
	var errorModal: (title: String, description: String)?
	
	init(email: String = "") {
		self.email = email
	}
	
	var isResetButtonDisabled: Bool {
		email.isTrimmedEmpty
	}
	
	func sendResetEmail() {
		loadingState.startLoading()
		shouldShowEmailRedBorder = false
		onBackgroundThread {
			auth.sendPasswordReset(withEmail: self.email).done {
				onMainThread {
					self.loadingState.succeed()
				}
			}.catch { error in
				onMainThread {
					self.failPasswordReset(error: error)
				}
			}
		}
	}
	
	func failPasswordReset(error: Error) {
		loadingState.fail(error: error)
		handleError(code: AuthErrorCode(error: error))
		shouldShowErrorModal = true
	}
	
	func applyError(title: String, description: String, invalidEmail: Bool) {
		errorModal = (title, description)
		shouldShowEmailRedBorder = invalidEmail
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
		case .tooManyRequests:
			applyError(
				title: "Too many requests",
				description: "Please try again later",
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

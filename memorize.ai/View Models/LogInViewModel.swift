import Combine
import FirebaseAuth
import GoogleSignIn
import PromiseKit

final class LogInViewModel: ViewModel {
	static let unknownErrorTitle = "Unknown error"
	static let unknownErrorDescription = "Sorry about that! Please try again"
	
	@Published var email = "" {
		didSet {
			guard loadingState.didFail else { return }
			shouldShowEmailRedBorder = false
		}
	}
	@Published var password = "" {
		didSet {
			guard loadingState.didFail else { return }
			shouldShowPasswordRedBorder = false
		}
	}
	
	@Published var shouldShowEmailRedBorder = false
	@Published var shouldShowPasswordRedBorder = false
	
	@Published var loadingState = LoadingState.none
	@Published var shouldShowErrorModal = false
	
	var user: User?
	var errorModal: (title: String, description: String)?
	
	var isLogInButtonDisabled: Bool {
		email.isTrimmedEmpty || password.isTrimmedEmpty
	}
	
	func logIn() {
		loadingState = .loading()
		shouldShowEmailRedBorder = false
		shouldShowPasswordRedBorder = false
		auth.signIn(
			withEmail: email,
			password: password
		).done { result in
			self.user = .init(
				id: result.user.uid,
				name: result.user.displayName ?? "Unknown",
				email: self.email,
				interests: []
			)
			self.loadingState = .success()
		}.catch(failLogIn)
	}
	
	func failLogIn(error: Error) {
		loadingState = .failure(message: error.localizedDescription)
		handleError(code: AuthErrorCode(error: error))
		shouldShowErrorModal = true
	}
	
	func applyError(
		title: String,
		description: String,
		invalidEmail: Bool,
		invalidPassword: Bool
	) {
		errorModal = (title, description)
		shouldShowEmailRedBorder = invalidEmail
		shouldShowPasswordRedBorder = invalidPassword
	}
	
	func handleError(code errorCode: AuthErrorCode?) {
		switch errorCode {
		case .invalidEmail:
			applyError(
				title: "Invalid email",
				description: "Your email should be of the form xyz@xyz.xyz",
				invalidEmail: true,
				invalidPassword: false
			)
		case .networkError:
			applyError(
				title: "Network error",
				description: "There was a problem connecting to our servers. Please try again",
				invalidEmail: false,
				invalidPassword: false
			)
		case .userNotFound:
			applyError(
				title: "Email not found",
				description: "There is no user with the email \(email). Would you like to sign up instead?",
				invalidEmail: true,
				invalidPassword: false
			)
		case .tooManyRequests:
			applyError(
				title: "Too many requests",
				description: "Please try again later",
				invalidEmail: false,
				invalidPassword: false
			)
		case .wrongPassword:
			applyError(
				title: "Incorrect passwod",
				description: "The password you entered was incorrect",
				invalidEmail: false,
				invalidPassword: true
			)
		default:
			applyError(
				title: Self.unknownErrorTitle,
				description: Self.unknownErrorDescription,
				invalidEmail: false,
				invalidPassword: false
			)
		}
	}
}

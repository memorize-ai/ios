import Combine
import FirebaseAuth
import FirebaseFirestore
import PromiseKit

final class SignUpViewModel: ViewModel {
	static let unknownErrorTitle = "Unknown error"
	static let unknownErrorDescription = "Sorry about that! Please try again"
	
	@Published var name = ""
	@Published var email = ""
	@Published var password = ""
	
	@Published var shouldShowNameRedBorder = false
	@Published var shouldShowEmailRedBorder = false
	@Published var shouldShowPasswordRedBorder = false
	
	@Published var loadingState = LoadingState.none
	@Published var shouldShowErrorModal = false
	
	var user: User?
	var errorModal: (title: String, description: String)?
	
	var isSignUpButtonDisabled: Bool {
		name.isTrimmedEmpty ||
		email.isTrimmedEmpty ||
		password.isTrimmedEmpty
	}
	
	func signUp() {
		loadingState = .loading()
		resetRedBorders()
		auth.createUser(
			withEmail: email,
			password: password
		).done { result in
			let uid = result.user.uid
			self.createUserInFirestore(uid: uid).done {
				self.setUser(uid: uid)
				self.loadingState = .success()
			}.catch(self.failFirestoreSignUp)
		}.catch(failAuthSignUp)
	}
	
	func setUser(uid: String) {
		user = .init(
			id: uid,
			name: name,
			email: email
		)
	}
	
	func createUserInFirestore(uid: String) -> Promise<Void> {
		firestore.document("users/\(uid)").setData([
			"name": name,
			"email": email
		])
	}
	
	func failAuthSignUp(error: Error) {
		loadingState = .failure(message: error.localizedDescription)
		handleAuthError(code: AuthErrorCode(error: error))
		shouldShowErrorModal = true
	}
	
	func failFirestoreSignUp(error: Error) {
		loadingState = .failure(message: error.localizedDescription)
		handleFirestoreError(code: FirestoreErrorCode(error: error))
		shouldShowErrorModal = true
	}
	
	func resetRedBorders() {
		shouldShowNameRedBorder = false
		shouldShowEmailRedBorder = false
		shouldShowPasswordRedBorder = false
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
	
	func handleAuthError(code errorCode: AuthErrorCode?) {
		switch errorCode {
		case .emailAlreadyInUse:
			applyError(
				title: "User already exists",
				description: "A user already exists with email \(email). Would you like to log in instead?",
				invalidEmail: true,
				invalidPassword: false
			)
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
		case .tooManyRequests:
			applyError(
				title: "Too many requests",
				description: "Please try again later",
				invalidEmail: false,
				invalidPassword: false
			)
		case .weakPassword:
			applyError(
				title: "Weak password",
				description: "Your password is easily guessed. Try another one",
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
	
	func handleFirestoreError(code errorCode: FirestoreErrorCode?) {
		// TODO: Handle firestore error
	}
}

import Combine
import FirebaseAuth
import FirebaseFirestore
import PromiseKit
import LoadingState

final class SignUpViewModel: ViewModel {
	static let unknownErrorTitle = "Unknown error"
	static let unknownErrorDescription = "Sorry about that! Please try again"
	
	@Published var name = "" {
		didSet {
			guard loadingState.didFail else { return }
			shouldShowNameRedBorder = false
		}
	}
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
	
	@Published var shouldShowNameRedBorder = false
	@Published var shouldShowEmailRedBorder = false
	@Published var shouldShowPasswordRedBorder = false
	
	@Published var loadingState = LoadingState()
	
	var user: User?
	
	var isSignUpButtonDisabled: Bool {
		name.isTrimmedEmpty ||
		email.isTrimmedEmpty ||
		password.isTrimmedEmpty
	}
	
	func signUp() {
		loadingState.startLoading()
		resetRedBorders()
		onBackgroundThread {
			auth.createUser(
				withEmail: self.email,
				password: self.password
			).done { result in
				let user = result.user
				let uid = user.uid
				
				changeUserName(user: user, name: self.name)
				
				self.createUserInFirestore(uid: uid).done {
					onMainThread {
						self.setUser(uid: uid)
						self.loadingState.succeed()
					}
				}.catch { error in
					onMainThread {
						self.failFirestoreSignUp(error: error)
					}
				}
			}.catch { error in
				onMainThread {
					self.failAuthSignUp(error: error)
				}
			}
		}
	}
	
	func setUser(uid: String) {
		user = .init(
			id: uid,
			name: name,
			email: email,
			interests: [],
			numberOfDecks: 0,
			xp: 0
		)
	}
	
	func createUserInFirestore(uid: String) -> Promise<Void> {
		firestore.document("users/\(uid)").setData([
			"name": name,
			"email": email,
			"joined": FieldValue.serverTimestamp(),
			"source": "ios",
			"method": "email"
		])
	}
	
	func failAuthSignUp(error: Error) {
		loadingState.fail(error: error)
		handleAuthError(code: AuthErrorCode(error: error))
	}
	
	func failFirestoreSignUp(error: Error) {
		loadingState.fail(error: error)
		handleFirestoreError(code: FirestoreErrorCode(error: error))
	}
	
	func resetRedBorders() {
		shouldShowNameRedBorder = false
		shouldShowEmailRedBorder = false
		shouldShowPasswordRedBorder = false
	}
	
	func applyError(
		title: String,
		message: String,
		invalidEmail: Bool,
		invalidPassword: Bool
	) {
		showAlert(title: title, message: message)
		shouldShowEmailRedBorder = invalidEmail
		shouldShowPasswordRedBorder = invalidPassword
	}
	
	func handleAuthError(code errorCode: AuthErrorCode?) {
		switch errorCode {
		case .accountExistsWithDifferentCredential:
			applyError(
				title: "Invalid sign in method",
				message: "You've already signed up with a different method",
				invalidEmail: false,
				invalidPassword: false
			)
		case .emailAlreadyInUse:
			applyError(
				title: "User already exists",
				message: "A user already exists with email \(email). Would you like to log in instead?",
				invalidEmail: true,
				invalidPassword: false
			)
		case .invalidEmail:
			applyError(
				title: "Invalid email",
				message: "Your email should be of the form xyz@xyz.xyz",
				invalidEmail: true,
				invalidPassword: false
			)
		case .networkError:
			applyError(
				title: "Network error",
				message: "There was a problem connecting to our servers. Please try again",
				invalidEmail: false,
				invalidPassword: false
			)
		case .tooManyRequests:
			applyError(
				title: "Too many requests",
				message: "Please try again later",
				invalidEmail: false,
				invalidPassword: false
			)
		case .weakPassword:
			applyError(
				title: "Weak password",
				message: "Your password is easily guessed. Try another one",
				invalidEmail: false,
				invalidPassword: true
			)
		default:
			applyError(
				title: Self.unknownErrorTitle,
				message: Self.unknownErrorDescription,
				invalidEmail: false,
				invalidPassword: false
			)
		}
	}
	
	func handleFirestoreError(code errorCode: FirestoreErrorCode?) {
		switch errorCode {
		case .dataLoss, .deadlineExceeded:
			applyError(
				title: "Network error",
				message: "There was a problem connecting to our servers. Please try again",
				invalidEmail: false,
				invalidPassword: false
			)
		case .permissionDenied:
			applyError(
				title: "Permission denied",
				message: "There was a problem with our servers. Please try again",
				invalidEmail: false,
				invalidPassword: false
			)
		case .resourceExhausted:
			applyError(
				title: "Server overload",
				message: "Our servers are overloaded right now. Please try again",
				invalidEmail: false,
				invalidPassword: false
			)
		default:
			applyError(
				title: Self.unknownErrorTitle,
				message: Self.unknownErrorDescription,
				invalidEmail: false,
				invalidPassword: false
			)
		}
	}
}

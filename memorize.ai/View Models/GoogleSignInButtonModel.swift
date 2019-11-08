import Combine
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import PromiseKit
import LoadingState

final class GoogleSignInButtonModel: ViewModel {
	static let unknownErrorTitle = "Unknown error"
	static let unknownErrorDescription = "Sorry about that! Please try again"
	
	@Published var loadingState = LoadingState()
	@Published var shouldShowErrorModal = false
	
	@Published var shouldProgressToHomeView = false
	@Published var shouldProgressToChooseTopicsView = false
	
	var user: User?
	var errorModal: (title: String, description: String)?
	
	func logIn() {
		GIDSignIn.completion = logInCompletion
		GIDSignIn.sharedInstance().presentingViewController =
			UIApplication.shared.windows.last?.rootViewController
		GIDSignIn.sharedInstance().signIn()
	}
	
	func logInCompletion(promise: Promise<AuthDataResult>) {
		loadingState = .loading
		promise.done { result in
			let user = result.user
			guard
				let email = user.email,
				let additionalInfo = result.additionalUserInfo
			else { return }
			let newUser = User(
				id: user.uid,
				name: user.displayName ?? "Unknown",
				email: email,
				interests: [],
				numberOfDecks: 0
			)
			self.user = newUser
			if additionalInfo.isNewUser {
				self.handleNewUser(from: newUser)
			} else {
				self.shouldProgressToHomeView = true
				self.loadingState = .success
			}
		}.catch(failAuthGoogleSignUp)
	}
	
	func handleNewUser(from user: User) {
		createUser(from: user).done {
			self.shouldProgressToChooseTopicsView = true
			self.loadingState = .success
		}.catch(failFirestoreGoogleSignUp)
	}
	
	func createUser(from user: User) -> Promise<Void> {
		firestore.document("users/\(user.id)").setData([
			"name": user.name,
			"email": user.email
		])
	}
	
	func failAuthGoogleSignUp(error: Error) {
		loadingState = .failure(message: error.localizedDescription)
		handleAuthError(code: AuthErrorCode(error: error))
	}
	
	func failFirestoreGoogleSignUp(error: Error) {
		loadingState = .failure(message: error.localizedDescription)
		handleFirestoreError(code: FirestoreErrorCode(error: error))
	}
	
	func applyError(title: String, description: String) {
		errorModal = (title, description)
		shouldShowErrorModal = true
	}
	
	func handleAuthError(code errorCode: AuthErrorCode?) {
		switch errorCode {
		case .networkError:
			applyError(
				title: "Network error",
				description: "There was a problem connecting to our servers. Please try again"
			)
		case .tooManyRequests:
			applyError(
				title: "Too many requests",
				description: "Please try again later"
			)
		default:
			return
		}
	}
	
	func handleFirestoreError(code errorCode: FirestoreErrorCode?) {
		switch errorCode {
		case .dataLoss, .deadlineExceeded:
			applyError(
				title: "Network error",
				description: "There was a problem connecting to our servers. Please try again"
			)
		case .permissionDenied:
			applyError(
				title: "Permission denied",
				description: "There was a problem with our servers. Please try again"
			)
		case .resourceExhausted:
			applyError(
				title: "Server overload",
				description: "Our servers are overloaded right now. Please try again"
			)
		default:
			applyError(
				title: Self.unknownErrorTitle,
				description: Self.unknownErrorDescription
			)
		}
	}
}

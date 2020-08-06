import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics
import GoogleSignIn
import PromiseKit
import LoadingState

final class GoogleSignInButtonModel: ViewModel {
	static let unknownErrorTitle = "Unknown error"
	static let unknownErrorDescription = "Sorry about that! Please try again"
	
	@Published var loadingState = LoadingState()
	
	@Published var shouldProgressToHomeView = false
	@Published var shouldProgressToChooseTopicsView = false
	
	var user: User?
	
	func logIn() {
		Analytics.logEvent(AnalyticsEventLogin, parameters: [
			"view": "GoogleSignInButton",
			AnalyticsParameterMethod: "google"
		])
		
		GIDSignIn.completion = logInCompletion
		GIDSignIn.sharedInstance().presentingViewController = currentViewController
		GIDSignIn.sharedInstance().signIn()
	}
	
	func logInCompletion(promise: Promise<AuthDataResult>) {
		loadingState.startLoading()
		onBackgroundThread {
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
					numberOfDecks: 0,
					xp: 0
				)
				
				self.user = newUser
				
				if additionalInfo.isNewUser {
					self.handleNewUser(from: newUser)
				} else {
					onMainThread {
						self.shouldProgressToHomeView = true
						self.loadingState.succeed()
					}
				}
			}.catch { error in
				onMainThread {
					self.failAuthGoogleSignUp(error: error)
				}
			}
		}
	}
	
	func handleNewUser(from user: User) {
		createUser(from: user).done {
			onMainThread {
				self.shouldProgressToChooseTopicsView = true
				self.loadingState.succeed()
			}
		}.catch { error in
			onMainThread {
				self.failFirestoreGoogleSignUp(error: error)
			}
		}
	}
	
	func createUser(from user: User) -> Promise<Void> {
		firestore.document("users/\(user.id)").setData([
			"name": user.name,
			"email": user.email,
			"joined": FieldValue.serverTimestamp(),
			"source": "ios",
			"method": "google"
		])
	}
	
	func failAuthGoogleSignUp(error: Error) {
		loadingState.fail(error: error)
		handleAuthError(code: AuthErrorCode(error: error))
	}
	
	func failFirestoreGoogleSignUp(error: Error) {
		loadingState.fail(error: error)
		handleFirestoreError(code: FirestoreErrorCode(error: error))
	}
	
	func handleAuthError(code errorCode: AuthErrorCode?) {
		switch errorCode {
		case .accountExistsWithDifferentCredential:
			showAlert(
				title: "Invalid sign in method",
				message: "You've already signed up with a different method"
			)
		case .networkError:
			showAlert(
				title: "Network error",
				message: "There was a problem connecting to our servers. Please try again"
			)
		case .tooManyRequests:
			showAlert(
				title: "Too many requests",
				message: "Please try again later"
			)
		default:
			return
		}
	}
	
	func handleFirestoreError(code errorCode: FirestoreErrorCode?) {
		switch errorCode {
		case .dataLoss, .deadlineExceeded:
			showAlert(
				title: "Network error",
				message: "There was a problem connecting to our servers. Please try again"
			)
		case .permissionDenied:
			showAlert(
				title: "Permission denied",
				message: "There was a problem with our servers. Please try again"
			)
		case .resourceExhausted:
			showAlert(
				title: "Server overload",
				message: "Our servers are overloaded right now. Please try again"
			)
		default:
			showAlert(
				title: Self.unknownErrorTitle,
				message: Self.unknownErrorDescription
			)
		}
	}
}

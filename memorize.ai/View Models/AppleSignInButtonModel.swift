import Combine
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics
import GoogleSignIn
import PromiseKit
import LoadingState

// swiftlint:disable:next line_length
final class AppleSignInButtonModel: NSObject, ViewModel, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
	static let unknownErrorTitle = "Unknown error"
	static let unknownErrorMessage = "Sorry about that! Please try again"
	
	@Published var loadingState = LoadingState()
	
	@Published var shouldProgressToHomeView = false
	@Published var shouldProgressToChooseTopicsView = false
	
	private(set) var user: User?
	private var nonce: String?
	
	func presentationAnchor(
		for controller: ASAuthorizationController
	) -> ASPresentationAnchor {
		currentViewController?.view?.window ?? UIWindow()
	}
	
	func authorizationController(
		controller: ASAuthorizationController,
		didCompleteWithAuthorization authorization: ASAuthorization
	) {
		guard
			let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
			let nonce = nonce,
			let rawToken = credential.identityToken,
			let token = String(data: rawToken, encoding: .utf8)
		else {
			showAlert(title: Self.unknownErrorTitle, message: Self.unknownErrorMessage)
			return
		}
		
		onBackgroundThread {
			auth.signIn(with: OAuthProvider.credential(
				withProviderID: "apple.com",
				idToken: token,
				rawNonce: nonce
			)).done { result in
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
					self.failAuthAppleSignUp(error: error)
				}
			}
		}
	}
	
	func authorizationController(
		controller: ASAuthorizationController,
		didCompleteWithError error: Error
	) {
		failAuthAppleSignUp(error: error)
	}
	
	func logIn() {
		Analytics.logEvent(AnalyticsEventLogin, parameters: [
			"view": "AppleSignInButton",
			AnalyticsParameterMethod: "apple"
		])
		
		nonce = UUID().uuidString
		
		let request = ASAuthorizationAppleIDProvider().createRequest()
		
		request.requestedScopes = [.fullName, .email]
		request.nonce = nonce.map(sha256)
		
		let controller = ASAuthorizationController(
			authorizationRequests: [request]
		)
		
		controller.delegate = self
		controller.presentationContextProvider = self
		
		controller.performRequests()
	}
	
	func handleNewUser(from user: User) {
		createUser(from: user).done {
			onMainThread {
				self.shouldProgressToChooseTopicsView = true
				self.loadingState.succeed()
			}
		}.catch { error in
			onMainThread {
				self.failFirestoreAppleSignUp(error: error)
			}
		}
	}
	
	func createUser(from user: User) -> Promise<Void> {
		firestore.document("users/\(user.id)").setData([
			"name": user.name,
			"email": user.email,
			"joined": FieldValue.serverTimestamp(),
			"source": "ios",
			"method": "apple"
		])
	}
	
	func failAuthAppleSignUp(error: Error) {
		loadingState.fail(error: error)
		
		if let error = error as? ASAuthorizationError {
			if error.code != .canceled {
				showAlert(title: Self.unknownErrorTitle, message: Self.unknownErrorMessage)
			}
		} else if let code = AuthErrorCode(error: error) {
			switch code {
			case .accountExistsWithDifferentCredential:
				showAlert(
					title: "Invalid sign in method",
					message: "You've already signed up with a different method"
				)
			default:
				showAlert(title: Self.unknownErrorTitle, message: Self.unknownErrorMessage)
			}
		} else {
			showAlert(title: Self.unknownErrorTitle, message: Self.unknownErrorMessage)
		}
	}
	
	func failFirestoreAppleSignUp(error: Error) {
		loadingState.fail(error: error)
		handleFirestoreError(code: FirestoreErrorCode(error: error))
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
				message: Self.unknownErrorMessage
			)
		}
	}
}

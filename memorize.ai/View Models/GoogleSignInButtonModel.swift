import Combine
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import PromiseKit

final class GoogleSignInButtonModel: ViewModel {
	@Published var loadingState = LoadingState.none
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
		loadingState = .loading()
		promise.done { result in
			let user = result.user
			guard
				let email = user.email,
				let additionalInfo = result.additionalUserInfo
			else { return }
			let newUser = User(
				id: user.uid,
				name: user.displayName ?? "Unknown",
				email: email
			)
			self.user = newUser
			if additionalInfo.isNewUser {
				self.handleNewUser(from: newUser)
			} else {
				self.shouldProgressToHomeView = true
				self.loadingState = .success()
			}
		}.catch(failAuthGoogleSignUp)
	}
	
	func handleNewUser(from user: User) {
		createUser(from: user).done {
			self.shouldProgressToChooseTopicsView = true
			self.loadingState = .success()
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
		shouldShowErrorModal = true
	}
	
	func failFirestoreGoogleSignUp(error: Error) {
		loadingState = .failure(message: error.localizedDescription)
		handleFirestoreError(code: FirestoreErrorCode(error: error))
		shouldShowErrorModal = true
	}
	
	func applyError(title: String, description: String) {
		errorModal = (title, description)
	}
	
	func handleAuthError(code errorCode: AuthErrorCode?) {
		// TODO: Switch over `errorCode`
	}
	
	func handleFirestoreError(code errorCode: FirestoreErrorCode?) {
		// TODO: Switch over `errorCode`
	}
}

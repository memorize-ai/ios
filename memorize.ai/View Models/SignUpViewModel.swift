import Combine
import FirebaseAuth
import PromiseKit

final class SignUpViewModel: ViewModel {
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
		// TODO: Fail auth sign up
	}
	
	func failFirestoreSignUp(error: Error) {
		// TODO: Fail firestore sign up
	}
	
	func resetRedBorders() {
		shouldShowNameRedBorder = false
		shouldShowEmailRedBorder = false
		shouldShowPasswordRedBorder = false
	}
}

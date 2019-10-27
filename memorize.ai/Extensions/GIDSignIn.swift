import GoogleSignIn
import FirebaseAuth
import PromiseKit

typealias GoogleSignInCompletion = (Promise<AuthDataResult>) -> Void

extension GIDSignIn {
	static var completion: GoogleSignInCompletion?
}

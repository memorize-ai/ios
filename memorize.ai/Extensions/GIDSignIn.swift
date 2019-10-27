import GoogleSignIn
import PromiseKit

typealias GoogleSignInCompletion = (Promise<GIDGoogleUser>) -> Void

extension GIDSignIn {
	static var completion: GoogleSignInCompletion?
}

import PromiseKit
import FirebaseAuth

extension Auth {
	func createUser(withEmail email: String, password: String) -> Promise<AuthDataResult> {
		.init { seal in
			createUser(withEmail: email, password: password) { result, error in
				guard error == nil, let result = result else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				seal.fulfill(result)
			}
		}
	}
	
	func signIn(withEmail email: String, password: String) -> Promise<AuthDataResult> {
		.init { seal in
			signIn(withEmail: email, password: password) { result, error in
				guard error == nil, let result = result else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				seal.fulfill(result)
			}
		}
	}
	
	func signIn(with credential: AuthCredential) -> Promise<AuthDataResult> {
		.init { seal in
			signIn(with: credential) { result, error in
				guard error == nil, let result = result else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				seal.fulfill(result)
			}
		}
	}
	
	func sendPasswordReset(withEmail email: String) -> Promise<Void> {
		.init { seal in
			sendPasswordReset(withEmail: email) { error in
				if let error = error {
					seal.reject(error)
				} else {
					seal.fulfill(())
				}
			}
		}
	}
	
	func signOutWithError() -> Error? {
		do {
			try signOut()
			return nil
		} catch {
			return error
		}
	}
}

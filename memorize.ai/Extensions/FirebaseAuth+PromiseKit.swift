import PromiseKit
import FirebaseAuth

extension Auth {
	func createUser(withEmail email: String, password: String) -> Promise<AuthDataResult> {
		Promise { seal in
			createUser(withEmail: email, password: password) { result, error in
				guard error == nil, let result = result else {
					return seal.reject(error ?? UnknownError.default)
				}
				seal.fulfill(result)
			}
		}
	}
}

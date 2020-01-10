import FirebaseFunctions
import PromiseKit

extension HTTPSCallable {
	func call(data: Any? = nil) -> Promise<HTTPSCallableResult> {
		.init { seal in
			call(data) { result, error in
				guard error == nil, let result = result else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				seal.fulfill(result)
			}
		}
	}
}

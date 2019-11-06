import PromiseKit
import FirebaseFirestore

extension DocumentReference {
	func setData(_ documentData: [String: Any]) -> Promise<Void> {
		.init { seal in
			setData(documentData) { error in
				if let error = error {
					seal.reject(error)
				} else {
					seal.fulfill(())
				}
			}
		}
	}
	
	func updateData(_ fields: [AnyHashable: Any]) -> Promise<Void> {
		.init { seal in
			updateData(fields) { error in
				if let error = error {
					seal.reject(error)
				} else {
					seal.fulfill(())
				}
			}
		}
	}
	
	func delete() -> Promise<Void> {
		.init { seal in
			delete { error in
				if let error = error {
					seal.reject(error)
				} else {
					seal.fulfill(())
				}
			}
		}
	}
}

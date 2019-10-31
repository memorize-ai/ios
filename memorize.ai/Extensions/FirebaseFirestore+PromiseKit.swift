import PromiseKit
import FirebaseFirestore

extension CollectionReference {
	func addSnapshotListener() -> Promise<QuerySnapshot> {
		.init { seal in
			addSnapshotListener { snapshot, error in
				guard error == nil, let snapshot = snapshot else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				seal.fulfill(snapshot)
			}
		}
	}
}

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
}

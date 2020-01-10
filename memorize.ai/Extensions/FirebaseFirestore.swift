import FirebaseFirestore
import PromiseKit

extension CollectionReference {
	func addDocument(data: [String: Any]) -> Promise<DocumentReference> {
		.init { seal in
			var documentReference: DocumentReference?
			documentReference = addDocument(data: data) { error in
				guard error == nil, let documentReference = documentReference else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				seal.fulfill(documentReference)
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

extension Query {
	func getDocuments() -> Promise<QuerySnapshot> {
		.init { seal in
			getDocuments { snapshot, error in
				guard error == nil, let snapshot = snapshot else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				seal.fulfill(snapshot)
			}
		}
	}
}

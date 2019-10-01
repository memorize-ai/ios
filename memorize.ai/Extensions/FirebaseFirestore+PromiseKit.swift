import PromiseKit
import FirebaseFirestore

extension CollectionReference {
	func addSnapshotListener() -> Promise<QuerySnapshot> {
		Promise { seal in
			addSnapshotListener { snapshot, error in
				guard error == nil, let snapshot = snapshot else {
					return seal.reject(error ?? UnknownError.default)
				}
				seal.fulfill(snapshot)
			}
		}
	}
}

extension DocumentReference {
	func addSnapshotListener() -> Promise<DocumentSnapshot> {
		Promise { seal in
			addSnapshotListener { snapshot, error in
				guard error == nil, let snapshot = snapshot else {
					return seal.reject(error ?? UnknownError.default)
				}
				seal.fulfill(snapshot)
			}
		}
	}
}

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
	func addSnapshotListener() -> Promise<DocumentSnapshot> {
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

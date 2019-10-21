import PromiseKit
import FirebaseStorage

extension StorageReference {
	func getData(maxSize: Int64 = FIREBASE_STORAGE_MAX_FILE_SIZE) -> Promise<Data> {
		Promise { seal in
			getData(maxSize: maxSize) { data, error in
				guard error == nil, let data = data else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				seal.fulfill(data)
			}
		}
	}
}

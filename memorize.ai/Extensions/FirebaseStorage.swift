import FirebaseStorage
import PromiseKit

extension StorageReference {
	func getData(maxSize: Int64 = FIREBASE_STORAGE_MAX_FILE_SIZE) -> Promise<Data> {
		.init { seal in
			getData(maxSize: maxSize) { data, error in
				guard error == nil, let data = data else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				seal.fulfill(data)
			}
		}
	}
	
	func putData(_ data: Data, metadata: StorageMetadata? = nil) -> Promise<Void> {
		.init { seal in
			putData(data, metadata: metadata) { _, error in
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

extension StorageMetadata {
	static var jpeg: StorageMetadata {
		let metadata = Self()
		metadata.contentType = "image/jpeg"
		return metadata
	}
}

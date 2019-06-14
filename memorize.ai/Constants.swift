import UIKit
import Firebase

let MAX_FILE_SIZE: Int64 = 50000000
let COMPRESSION_QUALITY: CGFloat = 0.5
let JPEG_METADATA: StorageMetadata = {
	let metadata = StorageMetadata()
	metadata.contentType = "image/jpeg"
	return metadata
}()
let DEFAULT_E = 2.5

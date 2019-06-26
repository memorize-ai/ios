import UIKit
import Firebase

let MAX_FILE_SIZE: Int64 = 50 * 1024 * 1024
let COMPRESSION_QUALITY: CGFloat = 0.5
let JPEG_METADATA = StorageMetadata.from(mime: "image/jpeg")
let DEFAULT_E = 2.5
let DEFAULT_PROFILE_PICTURE = #imageLiteral(resourceName: "Person")

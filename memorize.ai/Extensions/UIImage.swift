import UIKit

extension UIImage {
	var compressedData: Data? {
		jpegData(compressionQuality: IMAGE_COMPRESSION_QUALITY)
	}
}

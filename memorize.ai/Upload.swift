import Foundation
import Firebase
import SwiftyMimeTypes

var uploads = [Upload]()

class Upload {
	static let storage = Storage.storage(url: "gs://uploads.memorize.ai").reference()
	
	let id: String
	var name: String
	let created: Date
	var updated: Date
	var type: UploadType
	var mime: String
	var `extension`: String
	var size: String
	var data: Data?
	
	init(id: String, name: String, created: Date, updated: Date, type: UploadType, mime: String, extension: String, size: String, data: Data?) {
		self.id = id
		self.name = name
		self.created = created
		self.updated = updated
		self.type = type
		self.mime = mime
		self.extension = `extension`
		self.size = size
		self.data = data
	}
	
	private var cachedUrl: URL?
	var cachedImage: UIImage?
	var cachedAnimatedImage: UIImage?
	var shouldReload = false
	
	private var storageReference: StorageReference? {
		guard let uid = memorize_ai.id else { return nil }
		return Upload.storage.child("\(uid)/\(id)")
	}
	
	var filename: String {
		return "\(id).\(`extension`)"
	}
	
	var image: UIImage? {
		switch type {
		case .image, .gif:
			guard let data = data else { return nil }
			if cachedImage == nil {
				cachedImage = UIImage(data: data)
			}
			return cachedImage
		case .audio:
			return UPLOAD_SOUND_ICON
		}
	}
	
	var animatedImage: UIImage? {
		switch type {
		case .gif:
			guard let data = data else { return nil }
			if cachedAnimatedImage == nil {
				cachedAnimatedImage = UIImage.gif(data: data)
			}
			return cachedAnimatedImage
		default:
			return image
		}
	}
	
	func url(completion: @escaping (URL?, Error?) -> Void) {
		storageReference?.downloadURL(completion: completion)
	}
	
	static func loaded(_ filter: ((Upload) -> Bool)? = nil) -> [Upload] {
		return uploads.filter { $0.data != nil && (filter?($0) ?? true) }
	}
	
	static func filter(_ array: [Upload], for type: UploadType?) -> [Upload] {
		return array.filter { type == nil ? true : $0.type == type }
	}
	
	static func getNext(_ count: Int) -> [Upload] {
		return Array(uploads.filter { $0.data == nil }.prefix(count))
	}
	
	static func get(_ id: String) -> Upload? {
		return uploads.first { $0.id == id }
	}
	
	func url(completion: @escaping (URL?) -> Void) {
		if let cachedUrl = cachedUrl {
			completion(cachedUrl)
		} else {
			guard let storageReference = storageReference else { return completion(nil) }
			storageReference.downloadURL { url, error in
				guard error == nil, let url = url else { return completion(nil) }
				self.cachedUrl = url
				completion(url)
			}
		}
	}
	
	func load(completion: @escaping (Data?, Error?) -> Void) {
		storageReference?.getData(maxSize: MAX_FILE_SIZE) { data, error in
			guard error == nil, let data = data else { return completion(nil, error) }
			self.data = data
			completion(data, nil)
		}
	}
	
	func toMarkdown(_ url: String) -> String {
		switch type {
		case .image, .gif:
			return "![\(name)](\(url))"
		case .audio:
			return "<audio>\(url)</audio>"
		}
	}
	
	func update(_ snapshot: DocumentSnapshot) {
		name = snapshot.get("name") as? String ?? name
		updated = snapshot.getDate("updated") ?? updated
		type = UploadType(rawValue: snapshot.get("type") as? String ?? type.rawValue) ?? type
		mime = snapshot.get("mime") as? String ?? mime
		`extension` = snapshot.get("extension") as? String ?? `extension`
		size = snapshot.get("size") as? String ?? size
		shouldReload = true
	}
}

enum UploadType: String {
	case image = "image"
	case gif = "gif"
	case audio = "audio"
	
	init?(mime: String) {
		if mime == "image/gif" {
			self = .gif
		} else if mime.starts(with: "image/") {
			self = .image
		} else if mime.starts(with: "audio/") {
			self = .audio
		} else {
			return nil
		}
	}
	
	var formatted: String {
		switch self {
		case .image:
			return "Image"
		case .gif:
			return "Gif"
		case .audio:
			return "Audio"
		}
	}
}

func mimeTypeForExtension(_ ext: String) -> String? {
	switch ext {
	case "heic":
		return "image/heic"
	default:
		return MimeTypes.mimeType(forExtension: ext)
	}
}

func metadataForExtension(_ ext: String) -> StorageMetadata? {
	guard let mime = mimeTypeForExtension(ext) else { return nil }
	return StorageMetadata(mime: mime)
}

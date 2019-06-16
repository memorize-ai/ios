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
	var data: Data?
	var type: UploadType
	var mime: String
	var shouldReload = false
	
	init(id: String, name: String, created: Date, updated: Date, data: Data?, type: UploadType, mime: String) {
		self.id = id
		self.name = name
		self.created = created
		self.updated = updated
		self.data = data
		self.type = type
		self.mime = mime
	}
	
	private var storageReference: StorageReference? {
		guard let uid = memorize_ai.id, let filename = filename else { return nil }
		return Upload.storage.child("\(uid)/\(filename)")
	}
	
	var filename: String? {
		guard let ext = MimeTypes.filenameExtension(forType: mime) else { return nil }
		return "\(id).\(ext)"
	}
	
	func url(completion: @escaping (URL?, Error?) -> Void) {
		storageReference?.downloadURL(completion: completion)
	}
	
	static func loaded(_ filter: (Upload) -> Bool) -> [Upload] {
		return uploads.filter { $0.data != nil && filter($0) }
	}
	
	static func loaded() -> [Upload] {
		return loaded { _ in return true }
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
		shouldReload = true
	}
}

enum UploadType: String {
	case image = "image"
	case gif = "gif"
	case audio = "audio"
}

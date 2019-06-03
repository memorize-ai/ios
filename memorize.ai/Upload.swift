import Foundation
import Firebase

var uploads = [Upload]()

class Upload {
	static let storage = Storage.storage(url: "uploads.memorize.ai").reference()
	
	let id: String
	var name: String
	let created: Date
	var updated: Date
	var data: Data?
	var type: UploadType
	var shouldReload = false
	
	init(id: String, name: String, created: Date, updated: Date, data: Data?, type: UploadType) {
		self.id = id
		self.name = name
		self.created = created
		self.updated = updated
		self.data = data
		self.type = type
	}
	
	static func loaded(_ filter: (Upload) -> Bool) -> [Upload] {
		return uploads.filter { return $0.data != nil && filter($0) }
	}
	
	static func loaded() -> [Upload] {
		return loaded { _ in return true }
	}
	
	static func filter(_ array: [Upload], for type: UploadType?) -> [Upload] {
		return array.filter { return type == nil ? true : $0.type == type }
	}
	
	static func getNext(_ count: Int) -> [Upload] {
		return Array(uploads.filter { return $0.data == nil }.prefix(count))
	}
	
//	static func reloadAll() {
//		uploads.filter { return $0.shouldReload }.forEach {
//			storage.child
//		}
//	}
	
	static func get(_ id: String) -> Upload? {
		return uploads.first { return $0.id == id }
	}
	
	func load(completion: @escaping (Data?, Error?) -> Void) {
		Upload.storage.child("\(memorize_ai.id!)/\(id)").getData(maxSize: fileLimit) { data, error in
			guard error == nil, let data = data else { return completion(nil, error) }
			self.data = data
			completion(data, nil)
		}
	}
	
	func update(_ snapshot: DocumentSnapshot) {
		name = snapshot.get("name") as? String ?? name
		updated = snapshot.getDate("updated") ?? updated
		type = UploadType(rawValue: snapshot.get("type") as? String ?? type.rawValue) ?? type
		shouldReload = true
	}
}

enum UploadType: String {
	case image = "image"
	case video = "video"
	case audio = "audio"
}

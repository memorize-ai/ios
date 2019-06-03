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
	
	static func loaded() -> [Upload] {
		return uploads.filter { return $0.data != nil }
	}
	
	static func load(_ count: Int) {
		uploads.filter { return $0.data == nil }.prefix(count).forEach { $0.load() }
	}
	
	static func reloadAll() {
		uploads.filter { return $0.shouldReload }.forEach {
			storage.child
		}
	}
	
	static func get(_ id: String) -> Upload? {
		return uploads.first { return $0.id == id }
	}
	
	func load(completion: ) {
		Upload.storage.child("\(memorize_ai.id!)/\(id)").getData(maxSize: fileLimit) { data, error in
			guard error == nil, let data = data else { return }
			self.data = data
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

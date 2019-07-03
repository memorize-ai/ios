import UIKit
import CoreData

fileprivate let EXPIRATION_OFFSET_SECONDS: TimeInterval = 7 * 24 * 60 * 60

class Cache {
	static var decks = [Cache]()
	static var uploads = [Cache]()
	static var users = [Cache]()
	
	let type: ImageCacheType
	let key: String
	var image: UIImage?
	var data: Data?
	var properties: [String]
	var expiration: Date
	
	init(type: ImageCacheType, key: String, image: UIImage? = nil, data: Data? = nil, properties: [String] = []) {
		self.type = type
		self.key = key
		self.image = image
		self.data = data
		self.properties = properties
		expiration = Cache.getExpirationFromNow()
	}
	
	static func new(_ cache: Cache) {
		arrayForType(cache.type) {
			save(cache, array: &$0)
		}
	}
	
	private static func save(_ cache: Cache, array: inout [Cache]) {
		guard let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else { return }
		guard let entity = NSEntityDescription.entity(forEntityName: "ManagedCache", in: managedContext) else { return }
		let user = NSManagedObject(entity: entity, insertInto: managedContext)
		user.setValue(e, forKey: "email")
		user.setValue(p, forKey: "password")
		do {
			try managedContext.save()
			email = e
		} catch {}
	}
	
	private static func getExpirationFromNow() -> Date {
		return Date(timeIntervalSinceNow: EXPIRATION_OFFSET_SECONDS)
	}
	
	private static func arrayForType(_ type: ImageCacheType, completion: (inout [Cache]) -> Void) {
		switch type {
		case .deck:
			completion(&decks)
		case .upload:
			completion(&uploads)
		case .user:
			completion(&users)
		}
	}
	
	static func get(_ type: ImageCacheType, key: String) -> Cache {
		
	}
	
	static func remove(_ key: String) {
		
	}
	
	func hasProperty(_ property: String) -> Bool {
		return properties.first { $0 == property } != nil
	}
}

enum ImageCacheType: String {
	case deck = "deck"
	case upload = "upload"
	case user = "user"
	
	init(_ str: String) {
		self = ImageCacheType(rawValue: str) ?? .deck
	}
}

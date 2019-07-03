import UIKit
import CoreData

fileprivate let EXPIRATION_OFFSET_SECONDS: TimeInterval = 7 * 24 * 60 * 60

class Cache {
	static var decks = [Cache]()
	static var uploads = [Cache]()
	static var users = [Cache]()
	
	let type: CacheType
	let key: String
	var image: UIImage?
	var data: Data?
	var format: FileFormat
	var properties: [String]
	var expiration: Date
	
	init(type: CacheType, key: String, image: UIImage? = nil, data: Data? = nil, format: FileFormat, properties: [String] = [], expiration: Date = Cache.getExpirationFromNow()) {
		self.type = type
		self.key = key
		self.image = image
		self.data = data
		self.format = format
		self.properties = properties
		self.expiration = expiration
	}
	
	convenience init?(_ managedCache: ManagedCache) {
		guard let type = managedCache.value(forKey: "type") as? String, let key = managedCache.value(forKey: "key") as? String, let data = managedCache.value(forKey: "data") as? Data, let format = managedCache.value(forKey: "format") as? String, let properties = managedCache.value(forKey: "properties") as? [String], let expiration = managedCache.value(forKey: "expiration") as? Date else { return nil }
		let fileFormat = FileFormat(format)
		self.init(
			type: CacheType(type),
			key: key,
			image: Cache.imageForFormat(fileFormat, data: data),
			data: data,
			format: fileFormat,
			properties: properties,
			expiration: expiration
		)
	}
	
	private static func imageForFormat(_ format: FileFormat, data: Data) -> UIImage? {
		switch format {
		case .image:
			return UIImage(data: data)
		case .gif:
			return UIImage.gif(data: data)
		case .audio, .video:
			return nil
		}
	}
	
	static func new(_ cache: Cache) {
		arrayForType(cache.type) {
			save(cache, array: &$0)
		}
	}
	
	private static func save(_ cache: Cache, array: inout [Cache]) {
		guard let managedContext = managedContext, let entity = NSEntityDescription.entity(forEntityName: "ManagedCache", in: managedContext) else { return }
		let managedCache = NSManagedObject(entity: entity, insertInto: managedContext)
		managedCache.setValue(cache.type.rawValue, forKey: "type")
		managedCache.setValue(cache.key, forKey: "key")
		managedCache.setValue(cache.getData(), forKey: "data")
		managedCache.setValue(cache.properties, forKey: "properties")
		managedCache.setValue(cache.expiration, forKey: "expiration")
		guard saveManagedContext() else { return }
		array.append(cache)
	}
	
	private static func getExpirationFromNow() -> Date {
		return Date(timeIntervalSinceNow: EXPIRATION_OFFSET_SECONDS)
	}
	
	@discardableResult
	private static func arrayForType(_ type: CacheType, completion: ((inout [Cache]) -> Void)? = nil) -> [Cache] {
		switch type {
		case .deck:
			completion?(&decks)
			return decks
		case .upload:
			completion?(&uploads)
			return uploads
		case .user:
			completion?(&users)
			return users
		}
	}
	
	private static var managedCaches: [ManagedCache] {
		return (try? managedContext?.fetch(NSFetchRequest<NSManagedObject>(entityName: "ManagedCache")).compactMap { $0 as? ManagedCache }) ?? []
	}
	
	private static func getManagedCache(_ type: CacheType, key: String) -> ManagedCache? {
		return managedCaches.first { $0.value(forKey: "type") as? String == type.rawValue && $0.value(forKey: "key") as? String == key }
	}
	
	static func get(_ type: CacheType, key: String) -> Cache? {
		let expiration = getExpirationFromNow()
		if let managedCache = getManagedCache(type, key: key) {
			managedCache.setValue(expiration, forKey: "expiration")
			saveManagedContext()
		}
		arrayForType(type) {
			$0.first { $0.type == type && $0.key == key }?.expiration = expiration
		}
		return arrayForType(type).first { $0.type == type && $0.key == key }
	}
	
	@discardableResult
	static func remove(_ type: CacheType, key: String) -> Bool {
		guard let managedContext = managedContext, let managedCache = getManagedCache(type, key: key) else { return false }
		managedContext.delete(managedCache)
		arrayForType(type) {
			for i in 0..<$0.count {
				let cache = $0[i]
				if cache.type == type && cache.key == key {
					$0.remove(at: i)
					return
				}
			}
		}
		return true
	}
	
	func getData() -> Data? {
		return data ?? image?.pngData()
	}
	
	func hasProperty(_ property: String) -> Bool {
		return properties.first { $0 == property } != nil
	}
}

enum CacheType: String {
	case deck = "deck"
	case upload = "upload"
	case user = "user"
	
	init(_ str: String) {
		self = CacheType(rawValue: str) ?? .deck
	}
}

enum FileFormat: String {
	case image = "image"
	case gif = "gif"
	case video = "video"
	case audio = "audio"
	
	init(_ str: String) {
		self = FileFormat(rawValue: str) ?? .image
	}
}

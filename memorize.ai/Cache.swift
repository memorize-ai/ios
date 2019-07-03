import UIKit
import CoreData

fileprivate let EXPIRATION_OFFSET_SECONDS: TimeInterval = 7 * 24 * 60 * 60

class Cache {
	static var decks = [Cache]()
	static var uploads = [Cache]()
	static var users = [Cache]()
	static var didLoad = false
	
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
	
	var expired: Bool {
		return Cache.dateIsExpired(expiration)
	}
	
	static func loadAll() {
		didLoad = true
		removeAllExpired()
		managedCaches.compactMap { Cache($0) }.forEach { cache in
			if !cache.expired {
				arrayForType(cache.type) {
					$0.append(cache)
				}
			}
		}
	}
	
	static func removeAllExpired() {
		guard let managedContext = managedContext else { return }
		managedCaches.forEach {
			if Cache.dateIsExpired($0.value(forKey: "expiration") as? Date ?? Date(timeIntervalSince1970: 0)) {
				managedContext.delete($0)
				if let type = $0.value(forKey: "type") as? String, let key = $0.value(forKey: "key") as? String {
					let type = CacheType(type)
					arrayForType(type) {
						$0.removeAll { $0.key == key && $0.type == type }
					}
				}
			}
		}
	}
	
	static func removeAll() {
		guard let managedContext = managedContext else { return }
		managedCaches.forEach {
			managedContext.delete($0)
		}
		decks.removeAll()
		uploads.removeAll()
		users.removeAll()
	}
	
	static func new(_ cache: Cache) {
		arrayForType(cache.type) {
			save(cache, array: &$0)
		}
	}
	
	@discardableResult
	static func get(_ type: CacheType, key: String) -> Cache? {
		let expiration = getExpirationFromNow()
		if let managedCache = getManagedCache(type, key: key) {
			managedCache.setValue(expiration, forKey: "expiration")
			saveManagedContext()
		}
		arrayForType(type) {
			$0.first { $0.key == key && $0.type == type }?.expiration = expiration
		}
		return arrayForType(type).first { $0.key == key && $0.type == type }
	}
	
	@discardableResult
	static func remove(_ type: CacheType, key: String) -> Bool {
		guard let managedContext = managedContext, let managedCache = getManagedCache(type, key: key) else { return false }
		managedContext.delete(managedCache)
		arrayForType(type) {
			$0.removeAll { $0.key == key && $0.type == type }
		}
		return true
	}
	
	func getImage() -> UIImage? {
		if let image = image {
			return image
		}
		guard let data = data else {
			image = nil
			return nil
		}
		switch format {
		case .image:
			image = UIImage(data: data)
		case .gif:
			image = UIImage.gif(data: data)
		default:
			image = nil
			return nil
		}
		return image
	}
	
	func getData() -> Data? {
		return data ?? image?.jpegData(compressionQuality: 1)
	}
	
	func hasProperty(_ property: String) -> Bool {
		return properties.contains(property)
	}
	
	private static func dateIsExpired(_ date: Date) -> Bool {
		return Date().timeIntervalSince(date) >= 0
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
	
	private static func save(_ cache: Cache, array: inout [Cache]) {
		guard let managedContext = managedContext, let entity = NSEntityDescription.entity(forEntityName: "ManagedCache", in: managedContext) else { return }
		let managedCache = NSManagedObject(entity: entity, insertInto: managedContext)
		managedCache.setValue(cache.type.rawValue, forKey: "type")
		managedCache.setValue(cache.key, forKey: "key")
		managedCache.setValue(cache.getData(), forKey: "data")
		managedCache.setValue(cache.format.rawValue, forKey: "format")
		managedCache.setValue(cache.properties, forKey: "properties")
		managedCache.setValue(cache.expiration, forKey: "expiration")
		guard saveManagedContext() else { return }
		for i in 0..<array.count {
			let element = array[i]
			if element.key == cache.key && element.type == cache.type {
				array[i] = cache
				return
			}
		}
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

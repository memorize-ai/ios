import UIKit
import CoreData

fileprivate let EXPIRATION_OFFSET_SECONDS: TimeInterval = 5 * 24 * 60 * 60

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
	
	convenience init?(_ managedCache: NSManagedObject, type: CacheType) {
		guard let key = managedCache.value(forKey: "key") as? String, let format = managedCache.value(forKey: "format") as? String, let properties = managedCache.value(forKey: "properties") as? [String], let expiration = managedCache.value(forKey: "expiration") as? Int32 else { return nil }
		let fileFormat = FileFormat(format)
		self.init(
			type: type,
			key: key,
			data: managedCache.value(forKey: "data") as? Data,
			format: fileFormat,
			properties: properties,
			expiration: Date(timeIntervalSince1970: Double(expiration))
		)
		managed = managedCache
	}
	
	private var managed: NSManagedObject?
	
	var expired: Bool {
		return Cache.dateIsExpired(expiration)
	}
	
	static func removeAllExpired(type: CacheType? = nil) {
		if let type = type {
			guard let managedContext = managedContext else { return }
			let now = Date().timeIntervalSince1970
			guard let fetchRequest = Cache.fetchRequest(type: type) else { return }
			fetchRequest.predicate = NSPredicate(format: "expiration <= '\(now)'")
			guard let managedCaches = try? managedContext.fetch(fetchRequest) else { return }
			managedCaches.forEach {
				managedContext.delete($0)
				if let key = $0.value(forKey: "key") as? String {
					removeCache(type: type, key: key)
				}
			}
		} else {
			removeAllExpired(type: .deck)
			removeAllExpired(type: .upload)
			removeAllExpired(type: .user)
		}
	}
	
	static func new(_ type: CacheType, key: String, image: UIImage? = nil, data: Data? = nil, format: FileFormat, properties: [String] = [], expiration: Date = Cache.getExpirationFromNow()) {
		func setManagedCache(_ managedCache: NSManagedObject) {
			Cache.setManagedCache(managedCache, key: key, image: image, data: data, format: format, properties: properties, expiration: expiration)
		}
		func updateCache(_ cache: Cache) {
			cache.update(image: image, data: data, format: format, properties: properties, expiration: expiration)
		}
		func newManagedCache(_ cache: Cache) {
			guard let managedContext = managedContext, let entity = NSEntityDescription.entity(forEntityName: managedCacheName(type: type), in: managedContext) else { return }
			let managedCache = NSManagedObject(entity: entity, insertInto: managedContext)
			setManagedCache(managedCache)
			saveManagedContext()
			cache.managed = managedCache
		}
		arrayForType(type) {
			if let cache = ($0.first { $0.key == key }) {
				if let managedCache = cache.managed {
					setManagedCache(managedCache)
					saveManagedContext()
				} else {
					newManagedCache(cache)
				}
				updateCache(cache)
			} else {
				let cache = Cache(type: type, key: key, image: image, data: data, format: format, properties: properties, expiration: expiration)
				if let managedCache = getManagedCache(type, array: $0, key: key) {
					setManagedCache(managedCache)
					saveManagedContext()
				} else {
					newManagedCache(cache)
				}
				$0.append(cache)
			}
		}
	}
	
	@discardableResult
	static func get(_ type: CacheType, key: String) -> Cache? {
		var cache: Cache?
		switch type {
		case .deck:
			cache = decks.first { $0.key == key }
		case .upload:
			cache = uploads.first { $0.key == key }
		case .user:
			cache = users.first { $0.key == key }
		}
		if let cache = cache {
			let expiration = getExpirationFromNow()
			if let managedCache = cache.managed {
				managedCache.setValue(Int32(expiration.timeIntervalSince1970), forKey: "expiration")
				saveManagedContext()
			}
			cache.expiration = expiration
			return cache
		}
		if let managedCache = getManagedCache(type, key: key), let cache = Cache(managedCache, type: type) {
			switch type {
			case .deck:
				decks.append(cache)
			case .upload:
				uploads.append(cache)
			case .user:
				users.append(cache)
			}
			return cache
		}
		return nil
	}
	
	@discardableResult
	static func remove(_ type: CacheType, key: String) -> Bool {
		guard let managedContext = managedContext, let managedCache = getManagedCache(type, key: key) else { return false }
		managedContext.delete(managedCache)
		removeCache(type: type, key: key)
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
		case .image, .gif:
			image = UIImage(data: data)
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
	
	private func update(image: UIImage?, data: Data?, format: FileFormat, properties: [String], expiration: Date) {
		self.image = image
		self.data = data
		self.format = format
		self.properties = properties
		self.expiration = expiration
	}
	
	private static func dateIsExpired(_ date: Date) -> Bool {
		return Date().timeIntervalSince(date) >= 0
	}
	
	private static func getExpirationFromNow() -> Date {
		return Date(timeIntervalSinceNow: EXPIRATION_OFFSET_SECONDS)
	}
	
	private static func arrayForType(_ type: CacheType, completion: ((inout [Cache]) -> Void)? = nil) {
		switch type {
		case .deck:
			completion?(&decks)
		case .upload:
			completion?(&uploads)
		case .user:
			completion?(&users)
		}
	}
	
	private static func setManagedCache(_ managedCache: NSManagedObject, key: String, image: UIImage?, data: Data?, format: FileFormat, properties: [String], expiration: Date) {
		managedCache.setValue(key, forKey: "key")
		managedCache.setValue(data ?? image?.jpegData(compressionQuality: 1), forKey: "data")
		managedCache.setValue(format.rawValue, forKey: "format")
		managedCache.setValue(properties, forKey: "properties")
		managedCache.setValue(Int32(expiration.timeIntervalSince1970), forKey: "expiration")
	}
	
	private static func removeCache(type: CacheType, key: String) {
		switch type {
		case .deck:
			decks.removeAll { $0.key == key }
		case .upload:
			uploads.removeAll { $0.key == key }
		case .user:
			users.removeAll { $0.key == key }
		}
	}
	
	private static func getManagedCache(_ type: CacheType, array: [Cache]? = nil, key: String) -> NSManagedObject? {
		var cache: Cache?
		if let array = array {
			cache = array.first { $0.key == key }
		} else {
			switch type {
			case .deck:
				cache = decks.first { $0.key == key }
			case .upload:
				cache = uploads.first { $0.key == key }
			case .user:
				cache = users.first { $0.key == key }
			}
		}
		if let managedCache = cache?.managed {
			return managedCache
		}
		guard let fetchRequest = Cache.fetchRequest(type: type) else { return nil }
		fetchRequest.predicate = NSPredicate(format: "key = '\(key)'")
		guard let managedCache = try? managedContext?.fetch(fetchRequest).first else { return nil }
		cache?.managed = managedCache
		return managedCache
	}
	
	private static func fetchRequest(type: CacheType) -> NSFetchRequest<NSManagedObject>? {
		switch type {
		case .deck:
			return ManagedDeckCache.fetchRequest() as NSFetchRequest<ManagedDeckCache> as? NSFetchRequest<NSManagedObject>
		case .upload:
			return ManagedUploadCache.fetchRequest() as NSFetchRequest<ManagedUploadCache> as? NSFetchRequest<NSManagedObject>
		case .user:
			return ManagedUserCache.fetchRequest() as NSFetchRequest<ManagedUserCache> as? NSFetchRequest<NSManagedObject>
		}
	}
	
	private static func managedCacheName(type: CacheType) -> String {
		switch type {
		case .deck:
			return "ManagedDeckCache"
		case .upload:
			return "ManagedUploadCache"
		case .user:
			return "ManagedUserCache"
		}
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

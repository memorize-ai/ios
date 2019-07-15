import UIKit

var id: String?
var name: String?
var email: String?
var slug: String?
var profilePicture: UIImage?
var backgroundImage: UIImage?
var token: String?
var selectedDeckId: String?

class User {
	enum ImageType: String {
		case profilePicture = "profile"
		case backgroundImage = "background"
	}
	
	enum ImageFetchError: Error {
		case cacheNotFound
	}
	
	static var shouldShowViewProfileTip: Bool {
		get {
			return defaults.value(forKey: "shouldShowViewProfileTip") as? Bool ?? true
		}
		set {
			defaults.setValue(newValue, forKey: "shouldShowViewProfileTip")
		}
	}
	static var shouldShowEditCardTip: Bool {
		get {
			return defaults.value(forKey: "shouldShowEditCardTip") as? Bool ?? true
		}
		set {
			defaults.setValue(newValue, forKey: "shouldShowEditCardTip")
		}
	}
	
	@discardableResult
	static func cache(_ id: String, image: UIImage?, type: ImageType) -> UIImage? {
		Cache.new(.user, key: "\(type.rawValue)/\(id)", image: image, format: .image)
		return image
	}
	
	static func imageFromCache(_ id: String, type: ImageType) throws -> UIImage? {
		guard let cache = Cache.get(.user, key: "\(type.rawValue)/\(id)") else { throw ImageFetchError.cacheNotFound }
		return cache.getImage()
	}
	
	static func urlString(slug: String) -> String {
		return "u/\(slug)"
	}
	
	static func url(slug: String) -> URL? {
		return URL(string: "\(MEMORIZE_AI_BASE_URL)/\(urlString(slug: slug))")
	}
	
	static func getImageFromStorage(completion: @escaping (UIImage?, UIImage?) -> Void) {
		guard let id = id else { return completion(nil, nil) }
		func callCompletion(profile: UIImage?, profileData: Data?, background: UIImage?, backgroundData: Data?) {
			profilePicture = profile
			backgroundImage = background
			save(profilePicture: profileData)
			save(backgroundImage: backgroundData)
			cache(id, image: profile, type: .profilePicture)
			cache(id, image: background, type: .backgroundImage)
			completion(profile, background)
		}
		storage.child("users/\(id)/profile").getData(maxSize: MAX_FILE_SIZE) { data, error in
			var profile: (image: UIImage?, data: Data)?
			if error == nil, let data = data {
				profile = (UIImage(data: data), data)
			}
			storage.child("users/\(id)/background").getData(maxSize: MAX_FILE_SIZE) { data, error in
				if error == nil, let data = data {
					callCompletion(profile: profile?.image, profileData: profile?.data, background: UIImage(data: data), backgroundData: data)
				} else {
					callCompletion(profile: profile?.image, profileData: profile?.data, background: nil, backgroundData: nil)
				}
			}
		}
	}
	
	static func pushToken() {
		guard let id = id, let token = token else { return }
		firestore.document("users/\(id)/tokens/\(token)").setData(["enabled": true])
	}
	
	static func save() {
		guard let id = id, let name = name, let email = email else { return }
		defaults.set(id, forKey: "id")
		defaults.set(name, forKey: "name")
		defaults.set(email, forKey: "email")
		if let slug = slug {
			defaults.set(slug, forKey: "slug")
		}
		if let data = profilePicture?.jpegData(compressionQuality: 1) {
			defaults.set(data, forKey: "image")
		}
		if let selectedDeckId = selectedDeckId {
			save(selectedDeckId: selectedDeckId)
		}
	}
	
	static func save(profilePicture data: Data?) {
		if let data = data {
			defaults.set(data, forKey: "profilePicture")
		} else {
			defaults.removeObject(forKey: "profilePicture")
		}
	}
	
	static func save(backgroundImage data: Data?) {
		if let data = data {
			defaults.set(data, forKey: "backgroundImage")
		} else {
			defaults.removeObject(forKey: "backgroundImage")
		}
	}
	
	static func save(darkMode: Bool) {
		defaults.set(darkMode, forKey: "darkMode")
	}
	
	static func save(selectedDeckId deckId: String?) {
		selectedDeckId = deckId
		if let deckId = deckId {
			defaults.set(deckId, forKey: "selectedDeck")
		} else {
			defaults.removeObject(forKey: "selectedDeck")
		}
	}
	
	static func save(selectedDeck: Deck?) {
		save(selectedDeckId: selectedDeck?.id)
	}
	
	static func delete() {
		defaults.removeObject(forKey: "id")
		defaults.removeObject(forKey: "name")
		defaults.removeObject(forKey: "email")
		defaults.removeObject(forKey: "slug")
		defaults.removeObject(forKey: "profilePicture")
		defaults.removeObject(forKey: "backgroundImage")
		defaults.removeObject(forKey: "darkMode")
		save(selectedDeckId: nil)
		id = nil
		name = nil
		email = nil
		slug = nil
		profilePicture = nil
		token = nil
	}
	
	static func get() -> (id: String, name: String, email: String, slug: String?, image: UIImage?, darkMode: Bool, selectedDeckId: String?)? {
		guard let id = defaults.string(forKey: "id"), let name = defaults.string(forKey: "name"), let email = defaults.string(forKey: "email") else { return nil }
		return (
			id,
			name,
			email,
			defaults.string(forKey: "slug"),
			getImage(),
			defaults.bool(forKey: "darkMode"),
			defaults.string(forKey: "selectedDeck")
		)
	}
	
	static func getImage() -> UIImage? {
		guard let data = defaults.data(forKey: "image") else { return nil }
		return UIImage(data: data)
	}
}

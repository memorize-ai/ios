import UIKit
import Firebase

var id: String?
var name: String?
var email: String?
var slug: String?
var bio: String?
var reputation: Int?
var isEmailPublic: Bool?
var isContactAllowed: Bool?
var followersCount: Int?
var followingCount: Int?
var totalProfileViews: Int?
var uniqueProfileViews: Int?
var profilePicture: UIImage?
var backgroundImage: UIImage?
var token: String?
var selectedDeckId: String?

class User {
	enum ImageType: String {
		case profilePicture = "profile"
		case backgroundImage = "background"
		
		var description: String {
			switch self {
			case .profilePicture:
				return "profile picture"
			case .backgroundImage:
				return "background image"
			}
		}
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
	static var signedIn: Bool {
		return defaults.string(forKey: "id") != nil
	}
	
	static func getDynamicLink(id: String, name: String, slug: String, completion: @escaping (URL?) -> Void) {
		func callCompletion(_ url: URL?) {
			guard let url = url ?? URL(string: "https://firebasestorage.googleapis.com/v0/b/memorize-ai.appspot.com/o/static%2Fdefault-profile-picture.png?alt=media&token=5c5c8826-0eab-4234-a1a6-b7cfc5af021e") else { return completion(nil) }
			createDynamicLink(urlString(slug: slug), title: "\(name) on memorize.ai", description: "\(name)'s profile on memorize.ai", imageURL: url, completion: completion)
		}
		storage.child("users/\(id)/profile").downloadURL { callCompletion($1 == nil ? $0 : nil) }
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
	
	static func setFieldsWithSnapshot(_ snapshot: DocumentSnapshot) {
		name = snapshot.get("name") as? String ?? "Error"
		email = snapshot.get("email") as? String ?? "Error"
		slug = snapshot.get("slug") as? String
		bio = snapshot.get("bio") as? String ?? "Error"
		reputation = snapshot.get("reputation") as? Int ?? 0
		isEmailPublic = snapshot.get("publicEmail") as? Bool ?? true
		isContactAllowed = snapshot.get("allowContact") as? Bool ?? true
		followersCount = snapshot.get("followersCount") as? Int ?? 0
		followingCount = snapshot.get("followingCount") as? Int ?? 0
		let views = snapshot.get("views") as? [String : Any]
		totalProfileViews = views?["total"] as? Int ?? 0
		uniqueProfileViews = views?["unique"] as? Int ?? 0
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
		guard let id = id, let name = name, let email = email, let bio = bio, let reputation = reputation, let isEmailPublic = isEmailPublic, let isContactAllowed = isContactAllowed, let followersCount = followersCount, let followingCount = followingCount, let totalProfileViews = totalProfileViews, let uniqueProfileViews = uniqueProfileViews else { return }
		defaults.set(id, forKey: "id")
		defaults.set(name, forKey: "name")
		defaults.set(email, forKey: "email")
		defaults.set(bio, forKey: "bio")
		defaults.set(reputation, forKey: "reputation")
		defaults.set(isEmailPublic, forKey: "publicEmail")
		defaults.set(isContactAllowed, forKey: "allowContact")
		defaults.set(followersCount, forKey: "followers")
		defaults.set(followingCount, forKey: "following")
		defaults.set(totalProfileViews, forKey: "totalViews")
		defaults.set(uniqueProfileViews, forKey: "uniqueViews")
		if let slug = slug {
			defaults.set(slug, forKey: "slug")
		}
		if let data = profilePicture?.jpegData(compressionQuality: 1) {
			defaults.set(data, forKey: "profilePicture")
		}
		if let data = backgroundImage?.jpegData(compressionQuality: 1) {
			defaults.set(data, forKey: "backgroundImage")
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
		[
			"id",
			"name",
			"email",
			"bio",
			"slug",
			"reputation",
			"publicEmail",
			"allowContact",
			"followers",
			"following",
			"totalViews",
			"uniqueViews",
			"profilePicture",
			"backgroundImage",
			"darkMode"
		].forEach(defaults.removeObject(forKey:))
		save(selectedDeckId: nil)
		id = nil
		name = nil
		email = nil
		slug = nil
		bio = nil
		reputation = nil
		isEmailPublic = nil
		isContactAllowed = nil
		followersCount = nil
		followingCount = nil
		totalProfileViews = nil
		uniqueProfileViews = nil
		profilePicture = nil
		backgroundImage = nil
		token = nil
	}
	
	static func get() -> (id: String, name: String, email: String, slug: String?, bio: String, reputation: Int, isEmailPublic: Bool, isContactAllowed: Bool, followersCount: Int, followingCount: Int, totalProfileViews: Int, uniqueProfileViews: Int, profilePicture: UIImage?, backgroundImage: UIImage?, darkMode: Bool, selectedDeckId: String?)? {
		guard let id = defaults.string(forKey: "id"), let name = defaults.string(forKey: "name"), let email = defaults.string(forKey: "email"), let bio = defaults.string(forKey: "bio") else { return nil }
		return (
			id: id,
			name: name,
			email: email,
			slug: defaults.string(forKey: "slug"),
			bio: bio,
			reputation: defaults.integer(forKey: "reputation"),
			isEmailPublic: defaults.bool(forKey: "publicEmail"),
			isContactAllowed: defaults.bool(forKey: "allowContact"),
			followersCount: defaults.integer(forKey: "followers"),
			followingCount: defaults.integer(forKey: "following"),
			totalProfileViews: defaults.integer(forKey: "totalViews"),
			uniqueProfileViews: defaults.integer(forKey: "uniqueViews"),
			profilePicture: getImage(.profilePicture),
			backgroundImage: getImage(.backgroundImage),
			darkMode: defaults.bool(forKey: "darkMode"),
			selectedDeckId: defaults.string(forKey: "selectedDeck")
		)
	}
	
	static func getImage(_ type: ImageType) -> UIImage? {
		switch type {
		case .profilePicture:
			guard let data = defaults.data(forKey: "profilePicture") else { return nil }
			return UIImage(data: data)
		case .backgroundImage:
			guard let data = defaults.data(forKey: "backgroundImage") else { return nil }
			return UIImage(data: data)
		}
	}
}

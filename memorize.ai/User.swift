import UIKit

var id: String?
var name: String?
var email: String?
var slug: String?
var profilePicture: UIImage?
var token: String?
var selectedDeckId: String?

class User {
	static func urlString(slug: String) -> String {
		return "memorize.ai/u/\(slug)"
	}
	
	static func url(slug: String) -> URL? {
		return URL(string: "https://\(urlString(slug: slug))")
	}
	
	static func getImageFromStorage(completion: @escaping (UIImage?) -> Void) {
		guard let id = id else { return completion(nil) }
		func callCompletion(_ image: UIImage?, data: Data?) {
			profilePicture = image
			save(image: data)
			completion(image)
		}
		storage.child("users/\(id)").getData(maxSize: MAX_FILE_SIZE) { data, error in
			guard error == nil, let unwrappedData = data, let image = UIImage(data: unwrappedData) else { return callCompletion(nil, data: data) }
			callCompletion(image, data: unwrappedData)
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
	
	static func save(image: Data?) {
		if let image = image {
			defaults.set(image, forKey: "image")
		} else {
			defaults.removeObject(forKey: "image")
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
		defaults.removeObject(forKey: "image")
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

import UIKit

var id: String?
var name: String?
var email: String?
var slug: String?
var profilePicture: UIImage?
var token: String?

class User {
	static func getImageFromStorage(completion: @escaping (UIImage?) -> Void) {
		guard let id = id else { return completion(nil) }
		storage.child("users/\(id)").getData(maxSize: MAX_FILE_SIZE) { data, error in
			guard error == nil, let data = data, let image = UIImage(data: data) else { return completion(nil) }
			completion(image)
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
	}
	
	static func save(image: Data) {
		defaults.set(image, forKey: "image")
	}
	
	static func save(darkMode: Bool) {
		defaults.set(darkMode, forKey: "darkMode")
	}
	
	static func delete() {
		defaults.removeObject(forKey: "id")
		defaults.removeObject(forKey: "name")
		defaults.removeObject(forKey: "email")
		defaults.removeObject(forKey: "slug")
		defaults.removeObject(forKey: "image")
		defaults.removeObject(forKey: "darkMode")
		id = nil
		name = nil
		email = nil
		slug = nil
		profilePicture = nil
		token = nil
	}
	
	static func get() -> (id: String, name: String, email: String, slug: String?, image: UIImage?, darkMode: Bool)? {
		guard let id = defaults.string(forKey: "id"), let name = defaults.string(forKey: "name"), let email = defaults.string(forKey: "email"), let image = getImage() else { return nil }
		return (id, name, email, defaults.string(forKey: "slug"), image, defaults.bool(forKey: "darkMode"))
	}
	
	static func getImage() -> UIImage? {
		guard let data = defaults.data(forKey: "image") else { return nil }
		return UIImage(data: data)
	}
}

import UIKit

var id: String?
var name: String?
var email: String?
var slug: String?
var profilePicture: UIImage?
var token: String?

class User {
	static func pushToken() {
		guard let id = id, let token = token else { return }
		firestore.document("users/\(id)/tokens/\(token)").setData(["enabled": true])
	}
	
	static func save(email _email: String, password: String) {
		defaults.set(_email, forKey: "email")
		defaults.set(password, forKey: "password")
		email = _email
	}
	
	static func save(image: Data) {
		defaults.set(image, forKey: "image")
	}
	
	static func save(darkMode: Bool) {
		defaults.set(darkMode, forKey: "darkMode")
	}
	
	static func delete() {
		defaults.removeObject(forKey: "email")
		defaults.removeObject(forKey: "password")
		defaults.removeObject(forKey: "image")
		defaults.removeObject(forKey: "darkMode")
		id = nil
		name = nil
		email = nil
		slug = nil
		profilePicture = nil
		token = nil
	}
	
	static func get() -> (email: String, password: String, image: UIImage?, darkMode: Bool)? {
		guard let email = defaults.string(forKey: "email"), let password = defaults.string(forKey: "password"), let image = getImage() else { return nil }
		return (email, password, image, darkMode: defaults.bool(forKey: "darkMode"))
	}
	
	static func getImage() -> UIImage? {
		guard let data = defaults.data(forKey: "image") else { return nil }
		return UIImage(data: data)
	}
}

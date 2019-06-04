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
	
	static func save(email _email: String, password _password: String) {
		defaults.set(_email, forKey: "email")
		defaults.set(_password, forKey: "password")
		email = _email
	}
	
	static func save(image: Data) {
		defaults.set(image, forKey: "image")
	}
	
	static func delete() {
		defaults.set(nil, forKey: "email")
		defaults.set(nil, forKey: "password")
		defaults.set(nil, forKey: "image")
		id = nil
		name = nil
		email = nil
		slug = nil
		profilePicture = nil
		token = nil
	}
	
	static func get() -> (email: String, password: String, image: UIImage?)? {
		guard let email = defaults.string(forKey: "email"), let password = defaults.string(forKey: "password"), let image = getImage() else { return nil }
		return (email, password, image)
	}
	
	static func getImage() -> UIImage? {
		guard let data = defaults.data(forKey: "image") else { return nil }
		return UIImage(data: data)
	}
}

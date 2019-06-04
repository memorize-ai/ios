import UIKit

var id: String?
var name: String?
var email: String?
var slug: String?
var profilePicture: UIImage?
var token: String?

func pushToken() {
	guard let id = id, let token = token else { return }
	firestore.document("users/\(id)/tokens/\(token)").setData(["enabled": true])
}

func saveUser(email _email: String, password _password: String) {
	defaults.set(_email, forKey: "email")
	defaults.set(_password, forKey: "password")
	email = _email
}

func deleteUser() {
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

func saveImage(_ data: Data) {
	defaults.set(data, forKey: "image")
}

func getUser() -> (email: String, password: String, image: UIImage?)? {
	guard let email = defaults.string(forKey: "email"), let password = defaults.string(forKey: "password"), let image = getImage() else { return nil }
	return (email, password, image)
}

func getImage() -> UIImage? {
	guard let data = defaults.data(forKey: "image") else { return nil }
	return UIImage(data: data)
}

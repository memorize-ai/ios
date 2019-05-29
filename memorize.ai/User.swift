import UIKit
import CoreData

var id: String?
var name: String?
var email: String?
var slug: String?
var profilePicture: UIImage?
var invites = [Invite]()
var token: String?

func pushToken() {
	guard let id = id, let token = token else { return }
	firestore.document("users/\(id)/tokens/\(token)").setData(["enabled": true])
}

func saveUser(email e: String, password p: String) {
	guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
	let managedContext = appDelegate.persistentContainer.viewContext
	guard let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext) else { return }
	let user = NSManagedObject(entity: entity, insertInto: managedContext)
	user.setValue(e, forKey: "email")
	user.setValue(p, forKey: "password")
	do {
		try managedContext.save()
		email = e
	} catch {}
}

func deleteUser() {
	guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
	let managedContext = appDelegate.persistentContainer.viewContext
	let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
	do {
		let users = try managedContext.fetch(fetchRequest)
		guard let user = users.first else { return }
		managedContext.delete(user)
		id = nil
		name = nil
		email = nil
	} catch {}
}

func saveImage(_ data: Data) {
	guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
	let managedContext = appDelegate.persistentContainer.viewContext
	let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
	do {
		let users = try managedContext.fetch(fetchRequest)
		guard let user = users.first else { return }
		user.setValue(data, forKey: "image")
		try managedContext.save()
	} catch {}
}

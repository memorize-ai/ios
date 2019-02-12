import Foundation
import CoreData
import Firebase
import InstantSearchClient
import AudioToolbox

let firestore = Firestore.firestore()
let storage = Storage.storage().reference()
let client = Client(appID: "35UFDKN0J5", apiKey: "81d7ac9db3332e01c684c982e0bc3f02")
let decksIndex = client.index(withName: "decks")
var startup = true
var id: String?
var name: String?
var email: String?
var link: String?
var decks = [Deck]()

struct Deck {
	let id: String
	var image: UIImage
	var name: String
	var description: String
	var isPublic: Bool
	var count: Int
	var creator: Creator
	var owner: String
	var permissions: [Permission]
	var cards: [Card]
	
	static func id(_ t: String) -> Int? {
		for i in 0..<decks.count {
			if decks[i].id == t {
				return i
			}
		}
		return nil
	}
	
	func card(id t: String) -> Int? {
		for i in 0..<cards.count {
			if cards[i].id == t {
				return i
			}
		}
		return nil
	}
}

struct Card {
	let id: String
	var front: String
	var back: String
	var count: Int
	var correct: Int
	var streak: Int
	var last: Timestamp
	var next: Timestamp
	var history: [History]
	let deck: String
}

struct Creator {
	let id: String
	let name: String
}

struct Permission {
	let id: String
	let name: String
	let email: String
	var role: Role
}

enum Role: String {
	case editor = "editor"
	case viewer = "viewer"
	
	init?(_ string: String) {
		self = string == "editor" ? .editor : .viewer
	}
}

struct History {
	let id: String
	let date: Timestamp
	let next: Timestamp
	let correct: Bool
	let elapsed: Int
}

func saveLogin(email e: String, password p: String) {
	guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
	let managedContext = appDelegate.persistentContainer.viewContext
	guard let entity = NSEntityDescription.entity(forEntityName: "Login", in: managedContext) else { return }
	let login = NSManagedObject(entity: entity, insertInto: managedContext)
	login.setValue(e, forKeyPath: "email")
	login.setValue(p, forKeyPath: "password")
	do {
		try managedContext.save()
		email = e
	} catch {}
}

func deleteLogin() {
	guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
	let managedContext = appDelegate.persistentContainer.viewContext
	let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Login")
	do {
		let login = try managedContext.fetch(fetchRequest)
		if login.count == 1 {
			managedContext.delete(login[0])
			id = nil
			name = nil
			email = nil
		}
	} catch {}
}

extension UIViewController {
	func hideKeyboard() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func showAlert(_ title: String, _ message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(action)
		present(alertController, animated: true, completion: nil)
	}
	
	func showAlert(_ message: String) {
		AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
		showAlert("Error", message)
	}
}

extension String {
	func trim() -> String {
		return trimmingCharacters(in: .whitespaces)
	}
	
	func trimAll() -> String {
		return replacingOccurrences(of: " ", with: "")
	}
	
	func checkEmail() -> Bool {
		return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
	}
}

extension UIView {
	func roundCorners(corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		layer.mask = mask
	}
}

extension Timestamp {
	func beautify() -> String {
		let date = dateValue()
		let totalSeconds = Int(date.timeIntervalSinceNow)
		let hours = Int(totalSeconds / 3600)
		let minutes = totalSeconds - hours * 3600
		let seconds = totalSeconds - hours * 3600 - minutes * 60
		if hours < 2 {
			return hours < 1
		}
	}
}

import Foundation
import CoreData
import FirebaseFirestore
import FirebaseStorage
import InstantSearchClient
import AudioToolbox

let firestore = Firestore.firestore()
let storage = Storage.storage().reference()
let client = Client(appID: "35UFDKN0J5", apiKey: "81d7ac9db3332e01c684c982e0bc3f02")
let decksIndex = client.index(withName: "decks")
let fileLimit: Int64 = 50000000
var startup = true
var shouldLoadDecks = false
var id: String?
var name: String?
var email: String?
var slug: String?
var profilePicture: UIImage?
var decks = [Deck]()
var changeHandler: ((Change) -> Void)?
var token: String?

class Deck {
	let id: String
	var image: UIImage?
	var name: String
	var description: String
	var isPublic: Bool
	var count: Int
	var mastered: Int
	var creator: String
	var owner: String
	var permissions: [Permission]
	var cards: [Card]
	
	init(id: String, image: UIImage?, name: String, description: String, isPublic: Bool, count: Int, mastered: Int, creator: String, owner: String, permissions: [Permission], cards: [Card]) {
		self.id = id
		self.image = image
		self.name = name
		self.description = description
		self.isPublic = isPublic
		self.count = count
		self.mastered = mastered
		self.creator = creator
		self.owner = owner
		self.permissions = permissions
		self.cards = cards
	}
	
	static func id(_ t: String) -> Int? {
		for i in 0..<decks.count {
			if decks[i].id == t {
				return i
			}
		}
		return nil
	}
	
	static func allDue() -> [Card] {
		return decks.flatMap { return $0.cards.filter { return $0.isDue() } }
	}
	
	func card(id t: String) -> Int? {
		for i in 0..<cards.count {
			if cards[i].id == t {
				return i
			}
		}
		return nil
	}
	
	func allDue() -> [Card] {
		return cards.filter { return $0.isDue() }
	}
}

class Card {
	let id: String
	var front: String
	var back: String
	var count: Int
	var correct: Int
	var streak: Int
	var mastered: Bool
	var last: String
	var next: Date
	var history: [History]
	let deck: String
	
	init(id: String, front: String, back: String, count: Int, correct: Int, streak: Int, mastered: Bool, last: String, next: Date, history: [History], deck: String) {
		self.id = id
		self.front = front
		self.back = back
		self.count = count
		self.correct = correct
		self.streak = streak
		self.mastered = mastered
		self.last = last
		self.next = next
		self.history = history
		self.deck = deck
	}
	
	static func all() -> [Card] {
		return decks.flatMap { return $0.cards }
	}
	
	static func poll() {
		Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
			if !Deck.allDue().isEmpty {
				callChangeHandler(.cardDue)
			}
		}
	}
	
	func isDue() -> Bool {
		return next.timeIntervalSinceNow <= 0
	}
}

class Permission {
	let id: String
	var role: Role
	
	init(id: String, role: Role) {
		self.id = id
		self.role = role
	}
}

enum Role: String {
	case editor = "editor"
	case viewer = "viewer"
	
	init(_ string: String) {
		self = string == "editor" ? .editor : .viewer
	}
}

class History {
	let id: String
	let date: Date
	let next: Date
	let correct: Bool
	let elapsed: Int
	
	init(id: String, date: Date, next: Date, correct: Bool, elapsed: Int) {
		self.id = id
		self.date = date
		self.next = next
		self.correct = correct
		self.elapsed = elapsed
	}
}

enum Change {
	case profileModified
	case profilePicture
	case deckModified
	case deckRemoved
	case cardModified
	case cardRemoved
	case historyModified
	case historyRemoved
	case cardDue
}

func callChangeHandler(_ change: Change) {
	changeHandler?(change)
}

func updateChangeHandler(_ newChangeHandler: ((Change) -> Void)?) {
	changeHandler = newChangeHandler
}

func updateAndCallChangeHandler(_ change: Change, _ newChangeHandler: ((Change) -> Void)?) {
	updateChangeHandler(newChangeHandler)
	callChangeHandler(change)
}

func pushToken() {
	guard let id = id, let token = token else { return }
	firestore.document("users/\(id)/tokens/\(token)").setData(["enabled": true])
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

func saveImage(_ image: UIImage) {
	guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
	let managedContext = appDelegate.persistentContainer.viewContext
	let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Login")
	do {
		let logins = try managedContext.fetch(fetchRequest)
		guard let firstLogin = logins.first, let data = image.pngData() else { return }
		firstLogin.setValue(data, forKey: "image")
		try managedContext.save()
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
	func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		layer.mask = mask
	}
}

extension Date {
	func format(_ format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
	
	func format() -> String {
		return format("MMM d, yyyy @ h:mm a")
	}
	
	func elapsed() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.zeroFormattingBehavior = .dropAll
		formatter.maximumUnitCount = 1
		formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute]
		return "\(formatter.string(from: self, to: Date())!) ago"
	}
}

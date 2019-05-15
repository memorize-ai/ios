import Foundation
import CoreData
import FirebaseFirestore
import FirebaseStorage
import InstantSearchClient
import AudioToolbox
import WebKit
import Down

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
	var last: Last?
	var next: Date
	var history: [History]
	let deck: String
	
	init(id: String, front: String, back: String, count: Int, correct: Int, streak: Int, mastered: Bool, last: Last?, next: Date, history: [History], deck: String) {
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
	
	class Last {
		let id: String
		let date: Date
		let rating: Int
		let elapsed: Int
		
		init(id: String, date: Date, rating: Int, elapsed: Int) {
			self.id = id
			self.date = date
			self.rating = rating
			self.elapsed = elapsed
		}
	}
	
	static func all() -> [Card] {
		return decks.flatMap { return $0.cards }
	}
	
	static func poll() {
		Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
			if !Deck.allDue().isEmpty {
				ChangeHandler.call(.cardDue)
			}
		}
	}
	
	static func sortDue(_ cards: [Card]) -> [Card] {
		return cards.sorted { return $0.next.timeIntervalSinceNow < $1.next.timeIntervalSinceNow }
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

class Rating {
	static let ratings = [
		Rating(image: image(0), color: color(0), description: description(0)),
		Rating(image: image(1), color: color(1), description: description(1)),
		Rating(image: image(2), color: color(2), description: description(2)),
		Rating(image: image(3), color: color(3), description: description(3)),
		Rating(image: image(4), color: color(4), description: description(4)),
		Rating(image: image(5), color: color(5), description: description(5))
	]
	
	let image: UIImage
	let color: UIColor
	let description: String
	
	init(image: UIImage, color: UIColor, description: String) {
		self.image = image
		self.color = color
		self.description = description
	}
	
	static func get(_ rating: Int) -> Rating {
		return ratings[rating]
	}
	
	static func image(_ rating: Int) -> UIImage {
		return rating < 0 || rating > 5 ? #imageLiteral(resourceName: "Gray Circle") : UIImage(named: "Quality \(rating)") ?? #imageLiteral(resourceName: "Gray Circle")
	}
	
	static func color(_ rating: Int) -> UIColor {
		switch rating {
		case 0:
			return #colorLiteral(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
		case 1:
			return #colorLiteral(red: 0.7862434983, green: 0.4098072052, blue: 0.2144107223, alpha: 1)
		case 2:
			return #colorLiteral(red: 0.7540822029, green: 0.6499487758, blue: 0, alpha: 1)
		case 3:
			return #colorLiteral(red: 0.6504547, green: 0.7935678959, blue: 0, alpha: 1)
		case 4:
			return #colorLiteral(red: 0.3838550448, green: 0.7988399267, blue: 0, alpha: 1)
		case 5:
			return #colorLiteral(red: 0.2823529412, green: 0.8, blue: 0.4980392157, alpha: 1)
		default:
			return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		}
	}
	
	static func description(_ rating: Int) -> String {
		switch rating {
		case 0:
			return "Forgot"
		case 1:
			return "Kind of forgot"
		case 2:
			return "Almost remembered"
		case 3:
			return "Struggled and got it"
		case 4:
			return "Hesitated"
		case 5:
			return "Easy"
		default:
			return ""
		}
	}
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

extension WKWebView {
	func render(_ text: String, fontSize: Int, textColor: String, backgroundColor: String, markdown: Bool) {
		loadHTMLString("""
			<!DOCTYPE html>
			<html>
				<head>
					<link rel="stylesheet" href="katex.min.css">
					<script src="katex.min.js"></script>
					<script src="auto-render.min.js"></script>
					<style>
						html, body {
							font-size: \(fontSize)px;
							color: #\(textColor);
							background-color: #\(backgroundColor);
						}
						div {
							white-space: nowrap;
							overflow: hidden;
							text-overflow: ellipsis;
						}
					</style>
				</head>
				<body>
					<div>\(markdown ? (try? Down(markdownString: text).toHTML()) ?? text : text)</div>
					<script>renderMathInElement(document.body)</script>
				</body>
			</html>
		""", baseURL: URL(fileURLWithPath: Bundle.main.bundlePath, isDirectory: true))
	}
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

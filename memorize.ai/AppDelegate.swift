import UIKit
import CoreData
import Firebase
import UserNotifications
import FirebaseDynamicLinks
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
		FirebaseApp.configure()
		UNUserNotificationCenter.current().delegate = self
		registerForNotifications = {
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
			application.registerForRemoteNotifications()
		}
		Messaging.messaging().delegate = self
		Fabric.with([Crashlytics.self])
		return true
	}
	
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		guard let url = userActivity.webpageURL else { return false }
		return DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
			guard error == nil, let dynamicLink = dynamicLink?.url?.absoluteString else { return }
			let dynamicLinkId = String(dynamicLink.suffix(dynamicLink.count - "\(MEMORIZE_AI_BASE_URL)/d/".count))
			switch true {
			case dynamicLink.starts(with: "\(MEMORIZE_AI_BASE_URL)/d/"):
				func showDeck(hasImage: Bool, image: UIImage?) {
					if let currentViewController = currentViewController, User.signedIn {
						guard let deckVC = currentViewController.storyboard?.instantiateViewController(withIdentifier: "deck") as? DeckViewController else { return currentViewController.showNotification("Unable to load deck. Please try again", type: .error) }
						deckVC.deck.id = dynamicLinkId
						deckVC.deck.hasImage = hasImage
						deckVC.deck.image = image
						currentViewController.navigationController?.pushViewController(deckVC, animated: true)
					} else {
						pendingDynamicLink = .deck(id: dynamicLinkId, hasImage: hasImage)
					}
				}
				if let deck = Deck.get(dynamicLinkId) {
					showDeck(hasImage: deck.hasImage, image: deck.image)
				} else {
					firestore.document("decks/\(dynamicLinkId)").getDocument { snapshot, error in
						guard error == nil, let snapshot = snapshot else { return currentViewController?.showNotification("Unable to load deck. Please try again", type: .error) ?? () }
						showDeck(hasImage: snapshot.get("hasImage") as? Bool ?? false, image: nil)
					}
				}
			case dynamicLink.starts(with: "\(MEMORIZE_AI_BASE_URL)/u/"):
				print("user dynamic link") //$ Display user profile
			default:
				return
			}
		}
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
		User.pushToken()
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		saveContext()
	}
	
	lazy var persistentContainer: NSPersistentContainer = {
	    let container = NSPersistentContainer(name: "memorize_ai")
	    container.loadPersistentStores { storeDescription, error in
			guard let error = error as NSError? else { return }
			fatalError("Unresolved error \(error), \(error.userInfo)")
	    }
	    return container
	}()
	
	func saveContext() {
	    let context = persistentContainer.viewContext
	    if context.hasChanges {
	        do {
	            try context.save()
	        } catch let error as NSError {
	            fatalError("Unresolved error \(error), \(error.userInfo)")
	        }
	    }
	}
}

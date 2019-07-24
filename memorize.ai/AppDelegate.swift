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
			guard error == nil, let dynamicLink = dynamicLink?.url else { return }
			switch true {
			case dynamicLink.pathComponents.count == 3 && dynamicLink.pathComponents[1] == "d":
				let deckId = dynamicLink.pathComponents[2]
				func showDeck(hasImage: Bool, image: UIImage?) {
					if let currentViewController = currentViewController, User.signedIn {
						DeckViewController.show(currentViewController, id: deckId, hasImage: hasImage, image: image)
					} else {
						pendingDynamicLink = .deck(id: deckId, hasImage: hasImage)
					}
				}
				if let deck = Deck.get(deckId) {
					showDeck(hasImage: deck.hasImage, image: deck.image)
				} else {
					firestore.document("decks/\(deckId)").getDocument { snapshot, error in
						guard error == nil, let snapshot = snapshot else { return currentViewController?.showNotification("Unable to load deck. Please try again", type: .error) ?? () }
						showDeck(hasImage: snapshot.get("hasImage") as? Bool ?? false, image: nil)
					}
				}
			case dynamicLink.pathComponents.count == 3 && dynamicLink.pathComponents[1] == "u":
				print("user dynamic link") //$ Display user profile
			default:
				return
			}
		}
	}
	
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
		InstanceID.instanceID().instanceID { result, error in
			guard error == nil, let result = result else { return }
			token = result.token
		}
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
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

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

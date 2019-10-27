import UIKit
import CoreData
import FirebaseCore
import GoogleSignIn

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		FirebaseApp.configure()
		return true
	}
	
	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		.init(
			name: "Default Configuration",
			sessionRole: connectingSceneSession.role
		)
	}
	
	func application(
		_ app: UIApplication,
		open url: URL,
		options: [UIApplication.OpenURLOptionsKey: Any] = [:]
	) -> Bool {
		GIDSignIn.sharedInstance().handle(url)
	}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "memorize_ai")
		container.loadPersistentStores { _, error in
			#if DEBUG
			guard let error = error as NSError? else { return }
			fatalError("Unresolved error \(error), \(error.userInfo)")
			#endif
		}
		return container
	}()
	
	func saveContext() {
		let context = persistentContainer.viewContext
		guard context.hasChanges else { return }
		do {
			try context.save()
		} catch {
			#if DEBUG
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			#endif
		}
	}
}

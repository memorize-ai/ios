import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import PromiseKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		FirebaseApp.configure()
		
		GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
		GIDSignIn.sharedInstance().delegate = self
		
		StoreReview.onStartup()
		
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
	
	func sign(
		_ signIn: GIDSignIn!,
		didSignInFor user: GIDGoogleUser!,
		withError error: Error?
	) {
		guard let completion = GIDSignIn.completion else { return }
		guard error == nil, let userAuth = user.authentication else {
			return completion(.init(error: error ?? UNKNOWN_ERROR))
		}
		completion(auth.signIn(with: GoogleAuthProvider.credential(
			withIDToken: userAuth.idToken,
			accessToken: userAuth.accessToken
		)))
	}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "memorize_ai")
		container.loadPersistentStores { _, error in
			guard let error = error as NSError? else { return }
			fatalError("Unresolved error \(error), \(error.userInfo)")
		}
		return container
	}()
	
	func saveContext() {
		let context = persistentContainer.viewContext
		guard context.hasChanges else { return }
		do {
			try context.save()
		} catch let error as NSError {
			fatalError("Unresolved error \(error), \(error.userInfo)")
		}
	}
}

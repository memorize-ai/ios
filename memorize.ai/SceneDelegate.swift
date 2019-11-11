import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	var appDelegate: AppDelegate? {
		UIApplication.shared.delegate as? AppDelegate
	}
	
	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard
			let context = appDelegate?.persistentContainer.viewContext,
			let windowScene = scene as? UIWindowScene
		else { return }
		let window = UIWindow(windowScene: windowScene)
		if let currentUser = auth.currentUser {
			window.rootViewController = UIHostingController(
				rootView: MainTabView()
					.environmentObject(CurrentStore(user: .init(
						authUser: currentUser
					)))
					.environment(\.managedObjectContext, context)
			)
		} else {
			window.rootViewController = UIHostingController(
				rootView: InitialView()
					.environment(\.managedObjectContext, context)
			)
		}
		self.window = window
		window.makeKeyAndVisible()
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		appDelegate?.saveContext()
	}
}

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
			let currentUser = User(authUser: currentUser)
			window.rootViewController = HostingController(
				rootView: MainTabView(currentUser: currentUser)
					.environment(\.managedObjectContext, context)
					.environmentObject(CurrentStore(user: currentUser))
					.navigationBarRemoved()
			)
		} else {
			window.rootViewController = HostingController(
				rootView: InitialView()
					.environment(\.managedObjectContext, context)
					.navigationBarRemoved()
			)
		}
		self.window = window
		window.makeKeyAndVisible()
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		appDelegate?.saveContext()
	}
}

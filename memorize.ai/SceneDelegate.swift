import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard
			let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext,
			let windowScene = scene as? UIWindowScene
		else { return }
		let window = UIWindow(windowScene: windowScene)
		window.rootViewController = UIHostingController(
			rootView: InitialView()
				.environment(\.managedObjectContext, context)
		)
		self.window = window
		window.makeKeyAndVisible()
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
	}
}

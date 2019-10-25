import Combine

final class LogInViewModel: ObservableObject {
	@Published var email = ""
	@Published var password = ""
	@Published var user: User?
	@Published var loadingState = LoadingState.default {
		didSet {
			shouldGoToHomeView = loadingState.wasSuccessful
		}
	}
	@Published var shouldGoToHomeView = false
	
	func logIn() {
		loadingState = .loading()
		auth.signIn(
			withEmail: email,
			password: password
		).done { result in
			self.user = .init(
				id: result.user.uid,
				name: result.user.displayName ?? "Unknown",
				email: self.email
			)
			self.loadingState = .success()
		}.catch { error in
			self.loadingState = .failure(
				message: error.localizedDescription
			)
		}
	}
}

import Combine

final class LogInViewModel: ObservableObject {
	@Published var email = "" {
		didSet {
			guard loadingState.didFail else { return }
			loadingState = .none
		}
	}
	@Published var password = "" {
		didSet {
			guard loadingState.didFail else { return }
			loadingState = .none
		}
	}
	@Published var user: User?
	@Published var loadingState = LoadingState.none
	
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

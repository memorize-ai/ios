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
}

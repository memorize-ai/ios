import Combine

final class LogInViewModel: ObservableObject {
	@Published var email = ""
	@Published var password = ""
	@Published var user: User?
	@Published var loadingState = LoadingState.default
}

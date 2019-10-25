import Combine

final class LogInViewModel: ObservableObject {
	@Published var email = ""
	@Published var password = ""
	@Published var signedInUser: User?
}

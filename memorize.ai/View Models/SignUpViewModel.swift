import Combine

final class SignUpViewModel: ViewModel {
	@Published var name = ""
	@Published var email = ""
	@Published var password = ""
}

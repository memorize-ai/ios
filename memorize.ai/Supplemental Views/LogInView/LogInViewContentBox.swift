import SwiftUI

struct LogInViewContentBox: View {
	@ObservedObject var model: LogInViewModel
	
	var isLogInButtonDisabled: Bool {
		model.email.isEmpty || model.password.isEmpty
	}
	
	func logIn() {
		model.loadingState = .loading()
		let email = model.email
		auth.signIn(
			withEmail: email,
			password: model.password
		).done { result in
			self.model.user = .init(
				id: result.user.uid,
				name: result.user.displayName ?? "Unknown",
				email: email
			)
			self.model.loadingState = .success()
		}.catch { error in
			self.model.loadingState = .failure(
				message: error.localizedDescription
			)
		}
	}
	
	var body: some View {
		VStack(spacing: 20) {
			VStack(spacing: 32) {
				VStack(spacing: 12) {
					CustomTextField(
						$model.email,
						placeholder: "Email",
						contentType: .emailAddress,
						keyboardType: .emailAddress,
						capitalization: .none
					)
					CustomTextField(
						$model.password,
						placeholder: "Password",
						contentType: .password,
						capitalization: .none,
						secure: true
					)
				}
				Button(action: logIn) {
					CustomRectangle(
						backgroundColor: isLogInButtonDisabled
							? .disabledButtonBackground
							: .neonGreen
					) {
						Text("LOG IN")
							.font(.muli(.bold, size: 14))
							.foregroundColor(.white)
							.frame(maxWidth: .infinity)
							.frame(height: 40)
					}
				}
				.disabled(isLogInButtonDisabled)
			}
			NavigationLink(destination: ForgotPasswordView()) {
				Text("Forgot password?")
					.font(.muli(.bold, size: 12))
					.foregroundColor(.darkBlue)
			}
			if model.user != nil {
				NavigateTo(
					HomeView()
						.environmentObject(UserStore(model.user!)),
					when: $model.shouldGoToHomeView
				)
			}
		}
	}
}

#if DEBUG
struct LogInViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		LogInViewContentBox(model: LogInViewModel())
	}
}
#endif

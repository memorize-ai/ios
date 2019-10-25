import SwiftUI

struct LogInViewContentBox: View {
	@ObservedObject var model: LogInViewModel
	
	var isLogInButtonDisabled: Bool {
		model.email.isEmpty || model.password.isEmpty
	}
	
	func logIn() {
		auth.signIn(
			withEmail: model.email,
			password: model.password
		).done { result in
			print(result)
		}.catch { error in
			print(error)
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
						keyboardType: .emailAddress
					)
					CustomTextField(
						$model.password,
						placeholder: "Password",
						contentType: .password,
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

import SwiftUI

struct LogInViewContentBox: View {
	@State var email = ""
	@State var password = ""
	
	var isLogInButtonDisabled: Bool {
		email.isEmpty || password.isEmpty
	}
	
	var body: some View {
		VStack(spacing: 20) {
			VStack(spacing: 32) {
				VStack(spacing: 12) {
					CustomTextField(
						$email,
						placeholder: "Email",
						contentType: .emailAddress,
						keyboardType: .emailAddress
					)
					CustomTextField(
						$password,
						placeholder: "Password",
						contentType: .password,
						secure: true
					)
				}
				Button(action: {}) {
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
		LogInViewContentBox()
	}
}
#endif

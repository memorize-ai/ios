import SwiftUI

struct LogInViewContentBox: View {
	@State var email = ""
	@State var password = ""
	
	var body: some View {
		VStack(spacing: 20) {
			VStack(spacing: 32) {
				VStack(spacing: 12) {
					CustomTextField($email, placeholder: "Email")
					CustomTextField($password, placeholder: "Password")
				}
				Button(action: {}) {
					CustomRectangle(backgroundColor: .neonGreen) {
						Text("LOG IN")
							.font(.muli(.bold, size: 14))
							.foregroundColor(.white)
							.frame(maxWidth: .infinity)
							.frame(height: 40)
					}
				}
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

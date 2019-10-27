import SwiftUI
import GoogleSignIn

struct GoogleSignInButton: View {
	func logInWithGoogle() {
		GIDSignIn.sharedInstance().presentingViewController =
			UIApplication.shared.windows.last?.rootViewController
		GIDSignIn.sharedInstance().signIn()
	}
	
	var body: some View {
		Button(action: logInWithGoogle) {
			CustomRectangle(backgroundColor: .mediumGray) {
				HStack {
					Image("GoogleIcon")
						.resizable()
						.renderingMode(.original)
						.frame(width: 22, height: 22)
					Text("Sign in with Google")
						.font(.muli(.regular, size: 14))
						.foregroundColor(.darkText)
						.padding(.bottom, 3)
				}
				.frame(maxWidth: .infinity)
				.frame(height: 40)
			}
		}
	}
}

#if DEBUG
struct GoogleSignInButton_Previews: PreviewProvider {
	static var previews: some View {
		GoogleSignInButton()
	}
}
#endif

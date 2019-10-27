import SwiftUI

struct GoogleSignInButton: View {
	var body: some View {
		CustomRectangle(backgroundColor: .mediumGray) {
			HStack {
				Image("GoogleIcon")
					.resizable()
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

#if DEBUG
struct GoogleSignInButton_Previews: PreviewProvider {
	static var previews: some View {
		GoogleSignInButton()
	}
}
#endif

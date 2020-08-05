import SwiftUI
import AuthenticationServices

struct AppleSignInButton: UIViewRepresentable {
	func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
		ASAuthorizationAppleIDButton()
	}
	
	func updateUIView(_: ASAuthorizationAppleIDButton, context: Context) {}
}

#if DEBUG
struct AppleSignInButton_Previews: PreviewProvider {
	static var previews: some View {
		AppleSignInButton()
	}
}
#endif

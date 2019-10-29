import SwiftUI

struct ForgotPasswordView: View {
	let email: String
	
	init(email: String = "") {
		self.email = email
	}
	
	var body: some View {
		AuthenticationView(
			topGradient: [.bluePurple, .lightGreen],
			bottomGradient: [.lightGreen, .bluePurple],
			alternativeMessage: nil,
			alternativeButtonText: nil,
			alternativeButtonDestination: nil as EmptyView?,
			title: "Forgot password",
			contentBox: ForgotPasswordViewContentBox(model: .init(email: email))
		)
	}
}

#if DEBUG
struct ForgotPasswordView_Previews: PreviewProvider {
	static var previews: some View {
		ForgotPasswordView()
	}
}
#endif

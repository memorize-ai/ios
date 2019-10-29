import SwiftUI

struct ForgotPasswordView: View {
	let model: ForgotPasswordViewModel
	
	init(email: String = "") {
		model = .init(email: email)
	}
	
	var body: some View {
		AuthenticationView(
			model: model,
			topGradient: [.bluePurple, .lightGreen],
			bottomGradient: [.lightGreen, .bluePurple],
			alternativeMessage: nil,
			alternativeButtonText: nil,
			alternativeButtonDestination: nil as EmptyView?,
			title: "Forgot password",
			contentBox: ForgotPasswordViewContentBox(model: model)
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

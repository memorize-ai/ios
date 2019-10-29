import SwiftUI

struct SignUpView: View {
	let model = SignUpViewModel()
	
	var body: some View {
		AuthenticationView(
			model: model,
			topGradient: [.extraBluePurple, .darkerLightBlue],
			bottomGradient: [.darkerLightBlue, .extraBluePurple],
			alternativeMessage: "Already have an account?",
			alternativeButtonText: "LOG IN",
			alternativeButtonDestination: LogInView(),
			title: "Create your account",
			contentBox: SignUpViewContentBox(model: model)
		)
	}
}

#if DEBUG
struct SignUpView_Previews: PreviewProvider {
	static var previews: some View {
		SignUpView()
	}
}
#endif

import SwiftUI

struct SignUpView: View {
	var body: some View {
		AuthenticationView(
			topGradient: [.extraBluePurple, .darkerLightBlue],
			bottomGradient: [.darkerLightBlue, .extraBluePurple],
			alternativeMessage: "Already have an account?",
			alternativeButtonText: "LOG IN",
			alternativeButtonDestination: LogInView(),
			title: "Create your account",
			contentBox: SignUpViewContentBox(model: .init())
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

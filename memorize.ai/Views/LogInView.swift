import SwiftUI

struct LogInView: View {
	var body: some View {
		AuthenticationView(
			topGradient: [.bluePurple, .lightGreen],
			bottomGradient: [.lightGreen, .bluePurple],
			alternativeMessage: "Don't have an account yet?",
			alternativeButtonText: "SIGN UP",
			alternativeButtonDestination: SignUpView(),
			title: "Welcome back",
			contentBox: LogInViewContentBox(model: .init())
		)
	}
}

#if DEBUG
struct LogInView_Previews: PreviewProvider {
	static var previews: some View {
		previewForDevices([
			"iPhone 8 Plus",
			"iPhone XS Max",
			"iPhone SE"
		]) {
			LogInView()
		}
	}
}
#endif

import SwiftUI

struct LogInView: View {
	let model = LogInViewModel()
	
	var body: some View {
		AuthenticationView(
			model: model,
			topGradient: [.bluePurple, .lightGreen],
			bottomGradient: [.lightGreen, .bluePurple],
			alternativeMessage: "Don't have an account yet?",
			alternativeButtonText: "SIGN UP",
			alternativeButtonDestination: SignUpView(),
			title: "Welcome back",
			contentBox: LogInViewContentBox(model: model)
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

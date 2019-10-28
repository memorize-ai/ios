import SwiftUI

struct LogInView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var model = LogInViewModel()
	
	var body: some View {
		ZStack {
			AuthenticationViewBottomGradient(
				.lightGreen,
				.bluePurple
			)
			.align(to: .bottomTrailing)
			ZStack(alignment: .top) {
				AuthenticationViewTopGradient(
					.bluePurple,
					.lightGreen
				)
				AuthenticationViewTopControls(
					presentationMode: presentationMode,
					alternativeMessage: "Don't have an account yet?",
					alternativeButtonText: "SIGN UP",
					alternativeButtonDestination: SignUpView()
				)
			}
			.align(to: .top)
			AuthenticationViewContentBox(
				title: "Welcome back",
				content: LogInViewContentBox(model: model)
			)
		}
		.background(Color.lightGrayBackground)
		.edgesIgnoringSafeArea(.all)
		.removeNavigationBar()
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

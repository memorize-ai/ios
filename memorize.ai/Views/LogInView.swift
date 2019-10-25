import SwiftUI

struct LogInView: View {
	@Environment(\.presentationMode) var presentationMode

	@ObservedObject var model = LogInViewModel()
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				AuthenticationViewBottomGradient([
					.lightGreen,
					.bluePurple
				], screenWidth: geometry.size.width)
				.frame(maxWidth: .infinity, alignment: .trailing)
				.frame(maxHeight: .infinity, alignment: .bottom)
				ZStack(alignment: .top) {
					AuthenticationViewTopGradient([
						.bluePurple,
						.lightGreen
					], fullHeight: geometry.size.height)
					AuthenticationViewTopControls(
						presentationMode: self.presentationMode,
						alternativeMessage: "Don't have an account yet?",
						alternativeButtonText: "SIGN UP",
						alternativeButtonDestination: SignUpView()
					)
					AuthenticationViewContentBox(
						title: "Welcome back",
						content: LogInViewContentBox(model: self.model)
					)
				}
			}
		}
		.background(Color.lightGrayBackground)
		.edgesIgnoringSafeArea(.all)
	}
}

#if DEBUG
struct LogInView_Previews: PreviewProvider {
	static var previews: some View {
		LogInView()
	}
}
#endif

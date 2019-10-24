import SwiftUI

struct LogInView: View {
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		GeometryReader { geometry in
			VStack {
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
						content: LogInViewContentBox()
					)
				}
				AuthenticationViewBottomGradient([
					.lightGreen,
					.bluePurple
				], screenWidth: geometry.size.width)
				.frame(maxWidth: .infinity, alignment: .trailing)
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

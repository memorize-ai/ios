import SwiftUI
import FirebaseAnalytics

struct AuthenticationView<ContentBox: View, AlternativeDestination: View>: View {
	@Environment(\.presentationMode) var presentationMode
	
	let topGradient: [Color]
	let bottomGradient: [Color]
	let alternativeMessage: String?
	let alternativeButtonText: String?
	let alternativeButtonDestination: AlternativeDestination?
	let title: String
	let contentBox: ContentBox
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				AuthenticationViewBottomGradient(self.bottomGradient)
					.alignment(.bottomTrailing)
				ZStack(alignment: .top) {
					AuthenticationViewTopGradient(
						self.topGradient,
						addedHeight: geometry.safeAreaInsets.top
					)
					Group {
						if
							self.alternativeMessage == nil ||
							self.alternativeButtonText == nil ||
							self.alternativeButtonDestination == nil
						{
							Button(action: {
								Analytics.logEvent("authentication_view_dismissed", parameters: [
									"view": "AuthenticationView",
									"title": self.title
								])
								
								self.presentationMode.wrappedValue.dismiss()
							}) {
								LeftArrowHead(height: 20)
							}
							.alignment(.leading)
							.padding(.leading, 33)
						} else {
							AuthenticationViewTopControls(
								presentationMode: self.presentationMode,
								alternativeMessage: self.alternativeMessage!,
								alternativeButtonText: self.alternativeButtonText!,
								alternativeButtonDestination: self.alternativeButtonDestination!
							)
						}
					}
					.padding(.top, 20 + geometry.safeAreaInsets.top / 2)
				}
				.alignment(.top)
				AuthenticationViewContentBox(
					title: self.title,
					content: self.contentBox
				)
			}
			.background(Color.lightGrayBackground)
			.edgesIgnoringSafeArea(.all)
			.navigationBarRemoved()
		}
	}
}

#if DEBUG
struct AuthenticationView_Previews: PreviewProvider {
	static var previews: some View {
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
#endif

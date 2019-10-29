import SwiftUI

struct PostSignUpView<
	LeadingButton: View,
	TrailingButton: View,
	Content: View
>: View {
	let title: String
	let leadingButton: LeadingButton
	let trailingButton: TrailingButton
	let content: Content
	
	var body: some View {
		ZStack {
			AuthenticationViewBottomGradient([
				.darkerLightBlue,
				.extraBluePurple
			])
			.align(to: .bottomTrailing)
			ZStack(alignment: .top) {
				PostSignUpViewTopGradient()
				VStack {
					HStack {
						leadingButton
						Spacer()
						trailingButton
					}
					Text(title)
				}
				content
			}
			.align(to: .top)
		}
		.background(Color.lightGrayBackground)
		.edgesIgnoringSafeArea(.all)
	}
}

#if DEBUG
struct PostSignUpView_Previews: PreviewProvider {
	static var previews: some View {
		PostSignUpView(
			title: "Choose your interests",
			leadingButton: XButton(height: 20),
			trailingButton: XButton(height: 20), // TODO: Change this to NEXT button
			content: EmptyView()
		)
	}
}
#endif

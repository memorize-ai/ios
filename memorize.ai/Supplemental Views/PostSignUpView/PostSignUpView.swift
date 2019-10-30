import SwiftUI

struct PostSignUpView<
	LeadingButton: View,
	TrailingButtonDestination: View,
	Content: View
>: View {
	let title: String
	let leadingButton: LeadingButton
	let trailingButtonTitle: String
	let trailingButtonDestination: TrailingButtonDestination
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
						PostSignUpViewTrailingButton(
							text: trailingButtonTitle,
							destination: trailingButtonDestination
						)
					}
					.padding(.leading, 33)
					.padding(.trailing, 25)
					.padding(.top, 34)
					PostSignUpViewTitle(text: title)
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
			trailingButtonTitle: "NEXT",
			trailingButtonDestination: EmptyView(),
			content: EmptyView()
		)
	}
}
#endif

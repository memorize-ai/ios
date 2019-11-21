import SwiftUI

struct PostSignUpView<
	LeadingButton: View,
	TrailingButtonDestination: View,
	Content: View
>: View {
	@Environment(\.presentationMode) var presentationMode
	
	let title: String
	let leadingButton: LeadingButton
	let leadingButtonIsBackButton: Bool
	let trailingButtonTitle: String
	let trailingButtonDestination: TrailingButtonDestination
	let content: Content
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				AuthenticationViewBottomGradient([
					.darkerLightBlue,
					.extraBluePurple
				])
				.align(to: .bottomTrailing)
				ZStack(alignment: .top) {
					PostSignUpViewTopGradient(
						addedHeight: geometry.safeAreaInsets.top
					)
					VStack {
						HStack {
							if self.leadingButtonIsBackButton {
								Button(action: {
									self.presentationMode.wrappedValue.dismiss()
								}) {
									LeftArrowHead(height: 20)
								}
							} else {
								self.leadingButton
							}
							Spacer()
							PostSignUpViewTrailingButton(
								text: self.trailingButtonTitle,
								destination: self.trailingButtonDestination
							)
						}
						.padding(.leading, 33)
						.padding(.trailing, 25)
						.padding(.top, geometry.safeAreaInsets.top + 15)
						PostSignUpViewTitle(text: self.title)
						self.content
							.padding(.top)
					}
				}
				.align(to: .top)
			}
			.background(Color.lightGrayBackground)
			.removeNavigationBar()
			.edgesIgnoringSafeArea(.all)
		}
	}
}

#if DEBUG
struct PostSignUpView_Previews: PreviewProvider {
	static var previews: some View {
		PostSignUpView(
			title: "Choose your interests",
			leadingButton: XButton(.transparentWhite, height: 20),
			leadingButtonIsBackButton: false,
			trailingButtonTitle: "NEXT",
			trailingButtonDestination: EmptyView(),
			content: EmptyView()
		)
	}
}
#endif

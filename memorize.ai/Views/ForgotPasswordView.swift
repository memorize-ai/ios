import SwiftUI

struct ForgotPasswordView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var model: ForgotPasswordViewModel
	
	init(email: String = "") {
		model = .init(email: email)
	}
	
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
				Button(action: {
					self.presentationMode.wrappedValue.dismiss()
				}) {
					LeftArrowHead(height: 20)
				}
				.align(to: .leading)
				.padding(.leading, 33)
				.padding(.top, 34)
			}
			.align(to: .top)
			AuthenticationViewContentBox(
				title: "Forgot password",
				content: ForgotPasswordViewContentBox(model: model)
			)
		}
		.background(Color.lightGrayBackground)
		.edgesIgnoringSafeArea(.all)
		.removeNavigationBar()
	}
}

#if DEBUG
struct ForgotPasswordView_Previews: PreviewProvider {
	static var previews: some View {
		ForgotPasswordView()
	}
}
#endif

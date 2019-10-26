import SwiftUI

struct ForgotPasswordViewContentBox: View {
	@ObservedObject var model: ForgotPasswordViewModel
	
	var resetButtonContent: some View {
		model.loadingState.isLoading
			? AnyView(
				ActivityIndicator()
					.frame(maxWidth: .infinity)
					.frame(height: 40)
			)
			: AnyView(
				Text("RESET PASSWORD")
					.font(.muli(.bold, size: 14))
					.foregroundColor(.white)
					.frame(maxWidth: .infinity)
					.frame(height: 40)
			)
	}
	
	var body: some View {
		VStack(spacing: 14) {
			CustomTextField(
				$model.email,
				placeholder: "Email",
				contentType: .emailAddress,
				keyboardType: .emailAddress,
				capitalization: .none,
				borderColor: .darkRed,
				borderWidth: *model.shouldShowEmailRedBorder
			)
			Button(action: model.sendResetEmail) {
				CustomRectangle(
					backgroundColor: model.isResetButtonDisabled
						? .disabledButtonBackground
						: .neonGreen
				) {
					resetButtonContent
				}
			}
			.disabled(model.isResetButtonDisabled)
			Text("You will receive a password reset link for your registered email address")
				.font(.muli(.regular, size: 11))
				.foregroundColor(.darkText)
				.multilineTextAlignment(.center)
				.padding(.horizontal)
		}
		.padding(.top, 6)
	}
}

#if DEBUG
struct ForgotPasswordViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		ForgotPasswordViewContentBox(model: .init())
	}
}
#endif

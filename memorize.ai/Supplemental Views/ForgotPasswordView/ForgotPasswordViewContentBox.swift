import SwiftUI

struct ForgotPasswordViewContentBox: View {
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var model: ForgotPasswordViewModel
	
	func goBack() {
		presentationMode.wrappedValue.dismiss()
	}
	
	var shouldGoBack: some View {
		if model.loadingState.didSucceed {
			goBack()
		}
		return EmptyView()
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
					Group {
						if model.loadingState.isLoading {
							ActivityIndicator()
						} else {
							Text("RESET PASSWORD")
								.font(.muli(.bold, size: 14))
								.foregroundColor(.white)
						}
					}
					.frame(maxWidth: .infinity)
					.frame(height: 40)
				}
			}
			.disabled(model.isResetButtonDisabled)
			.alert(isPresented: $model.shouldShowErrorModal) {
				guard let errorModal = model.errorModal else {
					return .init(
						title: .init(LogInViewModel.unknownErrorTitle),
						message: .init(LogInViewModel.unknownErrorDescription)
					)
				}
				return .init(
					title: .init(errorModal.title),
					message: .init(errorModal.description)
				)
			}
			Text("You will receive a password reset link by email")
				.font(.muli(.regular, size: 11))
				.foregroundColor(.darkText)
				.multilineTextAlignment(.center)
				.padding(.horizontal)
			shouldGoBack
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

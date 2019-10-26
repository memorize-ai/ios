import SwiftUI

struct ForgotPasswordViewContentBox: View {
	@ObservedObject var model: ForgotPasswordViewModel
	
	var body: some View {
		VStack(spacing: 14) {
			CustomTextField(
				$model.email,
				placeholder: "Email",
				contentType: .emailAddress,
				keyboardType: .emailAddress,
				capitalization: .none
			)
			Button(action: {}) {
				CustomRectangle(
					backgroundColor: model.isResetButtonDisabled
						? .disabledButtonBackground
						: .neonGreen
				) {
					
				}
			}
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

import SwiftUI

struct SignUpViewContentBox: View {
	@ObservedObject var model: SignUpViewModel
	
	var body: some View {
		VStack(spacing: 32) {
			VStack(spacing: 12) {
				CustomTextField(
					$model.name,
					placeholder: "Name",
					contentType: .name,
					keyboardType: .alphabet,
					capitalization: .words,
					borderWidth: *model.shouldShowNameRedBorder
				)
				CustomTextField(
					$model.email,
					placeholder: "Email",
					contentType: .emailAddress,
					keyboardType: .emailAddress,
					capitalization: .none,
					borderWidth: *model.shouldShowEmailRedBorder
				)
				CustomTextField(
					$model.password,
					placeholder: "Password",
					contentType: .newPassword,
					capitalization: .none,
					secure: true,
					borderWidth: *model.shouldShowPasswordRedBorder
				)
			}
			Button(action: model.signUp) {
				CustomRectangle(
					backgroundColor: model.isSignUpButtonDisabled
						? .disabledButtonBackground
						: .darkBlue
				) {
					Group {
						if model.loadingState.isLoading {
							ActivityIndicator()
						} else {
							Text("SIGN UP")
								.font(.muli(.bold, size: 14))
								.foregroundColor(.white)
						}
					}
					.frame(maxWidth: .infinity)
					.frame(height: 40)
				}
			}
		}
	}
}

#if DEBUG
struct SignUpViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		SignUpViewContentBox(model: .init())
	}
}
#endif

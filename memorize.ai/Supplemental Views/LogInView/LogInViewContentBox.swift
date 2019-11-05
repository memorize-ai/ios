import SwiftUI

struct LogInViewContentBox: View {
	@ObservedObject var model: LogInViewModel
	
	var body: some View {
		VStack(spacing: 20) {
			VStack(spacing: 32) {
				VStack(spacing: 12) {
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
						contentType: .password,
						capitalization: .none,
						secure: true,
						borderWidth: *model.shouldShowPasswordRedBorder
					)
				}
				Button(action: model.logIn) {
					CustomRectangle(
						background: model.isLogInButtonDisabled
							? Color.disabledButtonBackground
							: Color.neonGreen
					) {
						Group {
							if model.loadingState.isLoading {
								ActivityIndicator()
							} else {
								Text("LOG IN")
									.font(.muli(.bold, size: 14))
									.foregroundColor(.white)
							}
						}
						.frame(maxWidth: .infinity)
						.frame(height: 40)
					}
				}
				.disabled(model.isLogInButtonDisabled)
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
			}
			NavigationLink(destination: ForgotPasswordView(email: model.email)) {
				Text("Forgot password?")
					.font(.muli(.bold, size: 12))
					.foregroundColor(.darkBlue)
			}
			AuthenticationViewOrText()
			GoogleSignInButton()
			if model.user != nil {
				NavigateTo(
					MainTabView()
						.environmentObject(UserStore(model.user!)),
					when: $model.loadingState.didSucceed
				)
			}
		}
	}
}

#if DEBUG
struct LogInViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		LogInViewContentBox(model: .init())
	}
}
#endif

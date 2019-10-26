import SwiftUI

struct LogInViewContentBox: View {
	@ObservedObject var model: LogInViewModel
	
	var navigateToHomeView: some View {
		guard let user = model.user else { return AnyView(EmptyView()) }
		return AnyView(
			NavigateTo(
				HomeView()
					.environmentObject(UserStore(user)),
				when: $model.loadingState.didSucceed
			)
		)
	}
	
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
						borderColor: .darkRed,
						borderWidth: *model.shouldShowEmailRedBorder
					)
					CustomTextField(
						$model.password,
						placeholder: "Password",
						contentType: .password,
						capitalization: .none,
						secure: true,
						borderColor: .darkRed,
						borderWidth: *model.shouldShowPasswordRedBorder
					)
				}
				Button(action: model.logIn) {
					CustomRectangle(
						backgroundColor: model.isLogInButtonDisabled
							? .disabledButtonBackground
							: .neonGreen
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
			navigateToHomeView
		}
	}
}

#if DEBUG
struct LogInViewContentBox_Previews: PreviewProvider {
	static var previews: some View {
		LogInViewContentBox(model: LogInViewModel())
	}
}
#endif

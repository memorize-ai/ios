import SwiftUI
import LoadingState

struct ProfileViewForgotPasswordButton: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@State var loadingState = LoadingState()
	
	func sendEmail() {
		loadingState.startLoading()
		onBackgroundThread {
			auth.sendPasswordReset(withEmail: self.currentStore.user.email).done {
				onMainThread {
					self.loadingState.succeed()
					showAlert(
						title: "Sent!",
						message: "Check your registered email to reset your password"
					)
				}
			}.catch { error in
				onMainThread {
					self.loadingState.fail(error: error)
					showAlert(
						title: "An unknown error occurred",
						message: "Please try again"
					)
				}
			}
		}
	}
	
	var body: some View {
		Button(action: sendEmail) {
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGrayBorder,
				borderWidth: 1
			) {
				Group {
					if loadingState.isLoading {
						ActivityIndicator(color: .darkBlue)
					} else {
						Text("Forgot password")
							.font(.muli(.semiBold, size: 16))
							.foregroundColor(.darkBlue)
							.shrinks()
					}
				}
				.frame(
					width: MailView.canSendMail
						? (SCREEN_SIZE.width - 8 * 3) / 2
						: SCREEN_SIZE.width - 8 * 2,
					height: 40
				)
			}
		}
		.padding(.top, 1 + (loadingState.isLoading ? -12 : 0))
	}
}

#if DEBUG
struct ProfileViewForgotPasswordButton_Previews: PreviewProvider {
	static var previews: some View {
		ProfileViewForgotPasswordButton()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

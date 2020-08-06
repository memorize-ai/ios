import SwiftUI

struct GoogleSignInButton: View {
	@ObservedObject var model = GoogleSignInButtonModel()
	
	var body: some View {
		Group {
			Button(action: model.logIn) {
				CustomRectangle(background: Color.mediumGray) {
					Group {
						if model.loadingState.isLoading {
							ActivityIndicator()
						} else {
							HStack {
								Image("GoogleIcon")
									.resizable()
									.renderingMode(.original)
									.aspectRatio(contentMode: .fit)
									.frame(width: 22, height: 22)
								Text("Sign in with Google")
									.font(.muli(.bold, size: 14))
									.foregroundColor(.darkText)
							}
						}
					}
					.frame(maxWidth: .infinity)
					.frame(height: 40)
				}
			}
			.disabled(model.loadingState == .loading)
			if model.user != nil {
				NavigateTo(
					CurrentStore(user: model.user!).rootDestination,
					when: $model.shouldProgressToHomeView
				)
				NavigateTo(
					ChooseTopicsView(currentUser: model.user!)
						.environmentObject(CurrentStore(
							user: model.user!
						))
						.navigationBarRemoved(),
					when: $model.shouldProgressToChooseTopicsView
				)
			}
		}
	}
}

#if DEBUG
struct GoogleSignInButton_Previews: PreviewProvider {
	static var previews: some View {
		GoogleSignInButton()
	}
}
#endif

import SwiftUI

struct AppleSignInButton: View {
	@ObservedObject var model = AppleSignInButtonModel()
	
	var body: some View {
		Group {
			Button(action: model.logIn) {
				CustomRectangle(background: Color.offBlack) {
					Group {
						if model.loadingState.isLoading {
							ActivityIndicator()
						} else {
							HStack {
								Image("AppleIcon")
									.resizable()
									.renderingMode(.original)
									.aspectRatio(contentMode: .fit)
									.frame(width: 22, height: 22)
								Text("Sign in with Apple")
									.font(.muli(.bold, size: 14))
									.foregroundColor(.white)
							}
						}
					}
					.frame(maxWidth: .infinity)
					.frame(height: 40)
				}
			}
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
struct AppleSignInButton_Previews: PreviewProvider {
	static var previews: some View {
		AppleSignInButton()
	}
}
#endif

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
									.frame(width: 22, height: 22)
								Text("Sign in with Google")
									.font(.muli(.regular, size: 14))
									.foregroundColor(.darkText)
									.padding(.bottom, 3)
							}
						}
					}
					.frame(maxWidth: .infinity)
					.frame(height: 40)
				}
			}
			.alert(isPresented: $model.shouldShowErrorModal) {
				guard let errorModal = model.errorModal else {
					return .init(
						title: .init(GoogleSignInButtonModel.unknownErrorTitle),
						message: .init(GoogleSignInButtonModel.unknownErrorDescription)
					)
				}
				return .init(
					title: .init(errorModal.title),
					message: .init(errorModal.description)
				)
			}
			if model.user != nil {
				NavigateTo(
					MainTabView()
						.environmentObject(CurrentStore(
							user: model.user!
						)),
					when: $model.shouldProgressToHomeView
				)
				NavigateTo(
					ChooseTopicsView(currentUser: model.user!)
						.environmentObject(CurrentStore(
							user: model.user!
						)),
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

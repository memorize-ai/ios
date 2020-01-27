import SwiftUI

struct ProfileView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				Group {
					Color.lightGrayBackground
					HomeViewTopGradient(
						addedHeight: geometry.safeAreaInsets.top
					)
				}
				.edgesIgnoringSafeArea(.all)
				VStack {
					ProfileViewTopControls()
						.padding(.horizontal, 23)
					ScrollView {
						ProfileViewMainCard(user: self.currentStore.user)
						ProfileViewForgotPasswordButton()
							.padding(.top, 8)
						ProfileViewCreatedDecksSection(user: self.currentStore.user)
						ProfileViewMyInterestsSection(user: self.currentStore.user)
					}
				}
			}
		}
	}
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
	static var previews: some View {
		ProfileView()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

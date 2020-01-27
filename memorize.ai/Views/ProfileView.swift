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
					Text("Profile")
						.font(.muli(.bold, size: 20))
						.foregroundColor(.white)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.horizontal, 23)
					ScrollView {
						ProfileViewMainCard(user: self.currentStore.user)
						ProfileViewForgotPasswordButton()
							.padding(.top, 8)
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

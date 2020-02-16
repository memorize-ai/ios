import SwiftUI

struct HomeView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				HomeViewTopGradient(
					addedHeight: geometry.safeAreaInsets.top
				)
				.edgesIgnoringSafeArea(.all)
				VStack(spacing: 20) {
					HomeViewTopControls()
						.padding(.horizontal, 23)
					ScrollView {
						VStack {
							HomeViewMyDecksSection(
								currentUser: self.currentStore.user
							)
							.padding(.top)
							HomeViewRecommendedDecksSection()
								.padding(.top, 5)
						}
						.frame(maxWidth: .infinity)
					}
				}
			}
		}
	}
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

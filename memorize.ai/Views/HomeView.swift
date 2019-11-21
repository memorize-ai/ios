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
						HomeViewPerformanceCard(
							currentUser: self.currentStore.user
						)
						.padding(.horizontal, 23)
						HomeViewRecommendedDecksSection()
							.padding(.top)
						HomeViewMyDecksSection(
							currentUser: self.currentStore.user
						)
						.padding(.top, 5)
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

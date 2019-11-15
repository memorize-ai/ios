import SwiftUI

struct HomeView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@Binding var isSideBarShowing: Bool
	
	var body: some View {
		ZStack(alignment: .top) {
			HomeViewTopGradient()
				.edgesIgnoringSafeArea(.all)
			VStack(spacing: 20) {
				HomeViewTopControls(
					isSideBarShowing: $isSideBarShowing
				)
				.padding(.horizontal, 23)
				ScrollView {
					HomeViewPerformanceCard()
						.padding(.horizontal, 23)
					HomeViewRecommendedDecksSection()
						.padding(.top)
					HomeViewMyDecksSection(
						currentUser: currentStore.user
					)
					.padding(.top)
				}
			}
		}
	}
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(isSideBarShowing: .constant(false))
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

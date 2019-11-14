import SwiftUI

struct HomeView: View {
	@Binding var isSideBarShowing: Bool
	
	var body: some View {
		ZStack(alignment: .top) {
			HomeViewTopGradient()
				.edgesIgnoringSafeArea(.all)
			VStack(spacing: 20) {
				HomeViewTopControls(
					isSideBarShowing: $isSideBarShowing
				)
				ScrollView {
					HomeViewPerformanceCard()
					HomeViewRecommendedDecksSection()
						.padding(.top)
				}
			}
			.padding(.horizontal, 23)
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

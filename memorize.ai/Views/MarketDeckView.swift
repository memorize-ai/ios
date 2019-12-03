import SwiftUI

struct MarketDeckView: View {
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				HomeViewTopGradient(
					addedHeight: geometry.safeAreaInsets.top
				)
				.edgesIgnoringSafeArea(.all)
				VStack(spacing: 20) {
					MarketDeckViewTopControls()
						.padding(.horizontal, 23)
					ScrollView {
						MarketDeckViewHeader()
						MarketDeckViewInfoPanels()
					}
				}
			}
		}
	}
}

#if DEBUG
struct MarketDeckView_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckView()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

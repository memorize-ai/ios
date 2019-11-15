import SwiftUI

struct OwnedDeckCellWithPerformanceGraph: View {
	@ObservedObject var deck: Deck
	
	var body: some View {
		Text(deck.name)
	}
}

#if DEBUG
struct OwnedDeckCellWithPerformanceGraph_Previews: PreviewProvider {
	static var previews: some View {
		OwnedDeckCellWithPerformanceGraph(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
	}
}
#endif

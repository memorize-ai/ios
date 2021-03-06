import SwiftUI

struct MarketDeckViewTopicList: View {
	static let cellDimension: CGFloat = 72
	
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var deck: Deck
	
	var topics: some View {
		ForEach(deck.topics(in: currentStore.topics), id: \.self) { topic in
			Group {
				if topic == nil {
					LoadingTopicCell(
						dimension: Self.cellDimension
					)
				} else {
					BasicTopicCell(
						topic: topic!,
						dimension: Self.cellDimension
					)
				}
			}
		}
	}
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			TryLazyHStack { self.topics }
				.padding(.horizontal, 23)
		}
	}
}

#if DEBUG
struct MarketDeckViewTopicList_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewTopicList()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

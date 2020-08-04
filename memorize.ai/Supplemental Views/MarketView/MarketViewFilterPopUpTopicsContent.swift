import SwiftUI

struct MarketViewFilterPopUpTopicsContent: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@Binding var topicsFilter: [Topic]?
	
	let isTopicSelected: (Topic) -> Bool
	let toggleTopicSelect: (Topic) -> Void
	
	func toggleSelect(forTopic topic: Topic) {
		if topicsFilter == nil {
			topicsFilter = currentStore.topics
		}
		toggleTopicSelect(topic)
	}
	
	var body: some View {
		ScrollView {
			TopicGrid(
				width: SCREEN_SIZE.width - 51 - TopicGrid.spacing * 2,
				topics: currentStore.topics,
				isSelected: isTopicSelected,
				toggleSelect: toggleSelect
			)
			.padding(.vertical, TopicGrid.spacing)
		}
	}
}

#if DEBUG
struct MarketViewFilterPopUpTopicsContent_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewFilterPopUpTopicsContent(
			topicsFilter: .constant([]),
			isTopicSelected: { _ in true },
			toggleTopicSelect: { _ in }
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

import SwiftUI
import QGrid

struct MarketViewFilterPopUpTopicsContent: View {
	static let availableWidth = SCREEN_SIZE.width - 51
	static let cellSpacing: CGFloat = 8
	static let numberOfColumns = Int(availableWidth - 16) / Int(TopicCell.dimension)
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@Binding var topicsFilter: [Topic]?
	
	let isTopicSelected: (Topic) -> Bool
	let toggleTopicSelect: (Topic) -> Void
	
	func topicCellToggleSelect(forTopic topic: Topic) {
		if topicsFilter == nil {
			topicsFilter = currentStore.topics
		}
		toggleTopicSelect(topic)
	}
	
	var body: some View {
		QGrid(
			currentStore.topics,
			columns: Self.numberOfColumns,
			vSpacing: Self.cellSpacing,
			hSpacing: Self.cellSpacing
		) { topic in
			TopicCell(
				topic: topic,
				isSelected: self.isTopicSelected(topic)
			) {
				self.topicCellToggleSelect(forTopic: topic)
			}
		}
		.frame(maxWidth: .infinity)
		.padding(.top, 8)
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

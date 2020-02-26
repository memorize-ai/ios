import SwiftUI
import QGrid

struct MarketViewFilterPopUpTopicsContent: View {
	static let gridWidth = SCREEN_SIZE.width - 51 - 8 * 2
	static let cellSpacing: CGFloat = 8
	static let numberOfColumns = numberOfGridColumns(
		width: gridWidth,
		cellWidth: TopicCell.dimension,
		horizontalSpacing: cellSpacing
	)
	
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
		.frame(maxWidth: Self.gridWidth)
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

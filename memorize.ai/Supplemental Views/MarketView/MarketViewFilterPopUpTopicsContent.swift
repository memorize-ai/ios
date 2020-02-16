import SwiftUI
import QGrid

struct MarketViewFilterPopUpTopicsContent: View {
	static let availableWidth = SCREEN_SIZE.width - 51
	static let cellSpacing: CGFloat = 8
	static let numberOfColumns = Int(availableWidth - 16) / Int(TopicCell.dimension)
	
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: MarketViewModel
	
	func topicCellToggleSelect(forTopic topic: Topic) {
		if model.topicsFilter == nil {
			model.topicsFilter = currentStore.topics
		}
		model.toggleTopicSelect(topic)
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
				isSelected: self.model.isTopicSelected(topic)
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
		MarketViewFilterPopUpTopicsContent()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(MarketViewModel(
				currentUser: PREVIEW_CURRENT_STORE.user
			))
	}
}
#endif

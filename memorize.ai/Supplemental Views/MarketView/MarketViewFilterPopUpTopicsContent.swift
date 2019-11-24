import SwiftUI

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
		ScrollView(showsIndicators: false) {
			Grid(
				elements: currentStore.topics.map { topic in
					TopicCell(
						topic: topic,
						isSelected: model.isTopicSelected(topic)
					) {
						self.topicCellToggleSelect(forTopic: topic)
					}
				},
				columns: Self.numberOfColumns,
				horizontalSpacing: Self.cellSpacing,
				verticalSpacing: Self.cellSpacing
			)
			.frame(maxWidth: .infinity)
			.padding(.top, 8)
		}
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

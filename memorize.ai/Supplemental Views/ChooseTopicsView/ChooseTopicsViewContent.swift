import SwiftUI
import QGrid

struct ChooseTopicsViewContent: View {
	static let cellSpacing: CGFloat = 8
	static let numberOfColumns = numberOfGridColumns(
		width: SCREEN_SIZE.width - 32,
		cellWidth: TopicCell.dimension,
		horizontalSpacing: cellSpacing
	)
	
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: ChooseTopicsViewModel
	
	var body: some View {
		VStack {
			if currentStore.topicsLoadingState.isLoading {
				ActivityIndicator(color: .white)
				Spacer()
			} else {
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
						self.model.toggleTopicSelect(topic)
					}
				}
				.gridFrame(
					columns: Self.numberOfColumns,
					numberOfCells: currentStore.topics.count,
					cellWidth: TopicCell.dimension,
					cellHeight: TopicCell.dimension,
					horizontalSpacing: Self.cellSpacing,
					verticalSpacing: Self.cellSpacing
				)
				.padding(.bottom)
			}
		}
		.onAppear {
			self.currentStore.loadAllTopics()
		}
	}
}

#if DEBUG
struct ChooseTopicsViewContent_Previews: PreviewProvider {
	static var previews: some View {
		ChooseTopicsViewContent()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(ChooseTopicsViewModel(
				currentUser: .init(
					id: "0",
					name: "Ken Mueller",
					email: "kenmueller0@gmail.com",
					interests: [],
					numberOfDecks: 0,
					xp: 0
				)
			))
	}
}
#endif

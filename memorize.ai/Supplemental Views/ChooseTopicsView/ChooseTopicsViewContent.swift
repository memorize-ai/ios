import SwiftUI

struct ChooseTopicsViewContent: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var model: ChooseTopicsViewModel
	
	init(currentUser: User) {
		model = .init(currentUser: currentUser)
	}
	
	static let cellSpacing: CGFloat = 8
	static let numberOfColumns = Int(SCREEN_SIZE.width) / Int(TopicCell.dimension)
	
	var body: some View {
		ScrollView(showsIndicators: false) {
			Grid(
				elements: currentStore.topics.map { topic in
					TopicCell(
						topic: topic,
						isSelected: model.isTopicSelected(topic)
					) {
						self.model.toggleTopicSelect(topic)
					}
				},
				columns: Self.numberOfColumns,
				horizontalSpacing: Self.cellSpacing,
				verticalSpacing: Self.cellSpacing
			)
			.frame(maxWidth: SCREEN_SIZE.width - 32)
		}
		.onAppear {
			self.currentStore.loadAllTopics()
		}
	}
}

#if DEBUG
struct ChooseTopicsViewContent_Previews: PreviewProvider {
	static var previews: some View {
		ChooseTopicsViewContent(currentUser: .init(
			id: "0",
			name: "Ken Mueller",
			email: "kenmueller0@gmail.com",
			interests: [],
			numberOfDecks: 0
		))
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

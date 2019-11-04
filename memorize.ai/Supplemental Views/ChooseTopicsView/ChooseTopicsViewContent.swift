import SwiftUI

struct ChooseTopicsViewContent: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	@ObservedObject var model: ChooseTopicsViewModel
	
	init(currentUser: User) {
		model = .init(currentUser: currentUser)
	}
	
	static let cellSpacing: CGFloat = 8
	static let numberOfColumns = Int(SCREEN_SIZE.width) / Int(TopicCell.dimension)
	
	var body: some View {
		ScrollView {
			Grid(
				elements: currentUserStore.topics.map { topic in
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
			guard self.currentUserStore.topicsLoadingState.isNone else { return }
			self.currentUserStore.loadTopics()
		}
	}
}

#if DEBUG
struct ChooseTopicsViewContent_Previews: PreviewProvider {
	static var previews: some View {
		let currentUser = User(
			id: "0",
			name: "Ken Mueller",
			email: "kenmueller0@gmail.com",
			interests: [],
			numberOfDecks: 0
		)
		return ChooseTopicsViewContent(currentUser: currentUser)
			.environmentObject(UserStore(currentUser))
	}
}
#endif

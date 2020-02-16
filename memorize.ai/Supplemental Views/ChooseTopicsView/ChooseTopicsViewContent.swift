import SwiftUI
import QGrid

struct ChooseTopicsViewContent: View {
	static let cellSpacing: CGFloat = 8
	static let numberOfColumns = Int(SCREEN_SIZE.width) / Int(TopicCell.dimension)
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var model: ChooseTopicsViewModel
	
	init(currentUser: User) {
		model = .init(currentUser: currentUser)
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
				self.model.toggleTopicSelect(topic)
			}
		}
		.frame(maxWidth: SCREEN_SIZE.width - 32)
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
			numberOfDecks: 0,
			xp: 0
		))
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

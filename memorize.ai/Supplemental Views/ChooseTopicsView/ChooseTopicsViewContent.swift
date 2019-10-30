import SwiftUI
import QGrid

struct ChooseTopicsViewContent: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	static let cellSpacing: CGFloat = 8
	static let numberOfColumns = Int(SCREEN_SIZE.width) / Int(TopicCell.dimension)
	
	var body: some View {
		QGrid(
			currentUserStore.topics,
			columns: Self.numberOfColumns,
			vSpacing: 8,
			hSpacing: 8
		) { topic in
			TopicCell(topic: topic)
		}
	}
}

#if DEBUG
struct ChooseTopicsViewContent_Previews: PreviewProvider {
	static var previews: some View {
		ChooseTopicsViewContent()
			.environmentObject(UserStore(.init(
				id: "0",
				name: "Ken Mueller",
				email: "kenmueller0@gmail.com"
			)))
	}
}
#endif

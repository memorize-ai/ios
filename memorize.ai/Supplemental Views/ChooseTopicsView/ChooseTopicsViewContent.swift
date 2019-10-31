import SwiftUI

struct ChooseTopicsViewContent: View {
	@EnvironmentObject var currentUserStore: UserStore
	
	static let cellSpacing: CGFloat = 8
	static let numberOfColumns = Int(SCREEN_SIZE.width) / Int(TopicCell.dimension)
	
	var body: some View {
		ScrollView {
			Grid(
				elements: currentUserStore.topics.map { TopicCell(topic: $0) },
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
		ChooseTopicsViewContent()
			.environmentObject(UserStore(.init(
				id: "0",
				name: "Ken Mueller",
				email: "kenmueller0@gmail.com"
			)))
	}
}
#endif

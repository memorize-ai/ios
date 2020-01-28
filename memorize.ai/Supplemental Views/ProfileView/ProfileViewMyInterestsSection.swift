import SwiftUI

struct ProfileViewMyInterestsSection: View {
	static let cellSpacing: CGFloat = 8
	static let numberOfColumns = Int(SCREEN_SIZE.width - 8 * 4) / Int(TopicCell.dimension)
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var user: User
	
	var body: some View {
		VStack {
			CustomRectangle(
				background: Color.lightGrayBackground.opacity(0.5)
			) {
				Text("My interests")
					.font(.muli(.bold, size: 20))
					.foregroundColor(.darkGray)
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
			}
			.frame(width: SCREEN_SIZE.width - 8 * 2, alignment: .leading)
			CustomRectangle(
				background: Color.white,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				Grid(
					elements: currentStore.topics.map { topic in
						TopicCell(
							topic: topic,
							isSelected: user.interests.contains(topic.id)
						) {
							_ = self.user.interests.contains(topic.id)
								? self.user.removeInterest(topicId: topic.id)
								: self.user.addInterest(topicId: topic.id)
						}
					},
					columns: Self.numberOfColumns,
					horizontalSpacing: Self.cellSpacing,
					verticalSpacing: Self.cellSpacing
				)
				.frame(width:
					.init(Self.numberOfColumns) * TopicCell.dimension +
					.init(Self.numberOfColumns - 1) * Self.cellSpacing
				)
				.frame(width: SCREEN_SIZE.width - 8 * 2)
				.padding(.vertical, 8)
			}
		}
		.padding(.top)
		.onAppear {
			self.currentStore.loadAllTopics()
		}
	}
}

#if DEBUG
struct ProfileViewMyInterestsSection_Previews: PreviewProvider {
	static var previews: some View {
		ProfileViewMyInterestsSection(
			user: PREVIEW_CURRENT_STORE.user
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

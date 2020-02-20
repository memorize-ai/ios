import SwiftUI
import QGrid

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
				borderColor: .lightGray,
				borderWidth: 1.5,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				QGrid(
					currentStore.topics,
					columns: Self.numberOfColumns,
					vSpacing: Self.cellSpacing,
					hSpacing: Self.cellSpacing,
					isScrollable: false
				) { topic in
					TopicCell(
						topic: topic,
						isSelected: self.user.interests.contains(topic.id)
					) {
						_ = self.user.interests.contains(topic.id)
							? self.user.removeInterest(topicId: topic.id)
							: self.user.addInterest(topicId: topic.id)
					}
				}
				.frame(width:
					.init(Self.numberOfColumns) * TopicCell.dimension +
					.init(Self.numberOfColumns - 1) * Self.cellSpacing
				)
				.frame(
					width: SCREEN_SIZE.width - 8 * 2,
					height: heightOfGrid(
						columns: Self.numberOfColumns,
						numberOfCells: currentStore.topics.count,
						cellHeight: TopicCell.dimension,
						spacing: Self.cellSpacing
					)
				)
				.padding(.vertical, 8)
				.padding(.bottom)
			}
		}
		.padding(.vertical)
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

import SwiftUI

struct ProfileViewMyInterestsSection: View {
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
				TopicGrid(
					width: SCREEN_SIZE.width - TopicGrid.spacing * 4,
					topics: currentStore.topics,
					isSelected: { self.user.interests.contains($0.id) },
					toggleSelect: {
						_ = self.user.interests.contains($0.id)
							? self.user.removeInterest(topicId: $0.id)
							: self.user.addInterest(topicId: $0.id)
					}
				)
				.padding(TopicGrid.spacing)
				.frame(width: SCREEN_SIZE.width - 8 * 2)
			}
		}
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

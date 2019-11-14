import SwiftUI

struct HomeViewTopicPerformanceList: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack {
				ForEach(currentStore.user.interests, id: \.self) { topicId in
					Text(topicId) // TODO: Replace with topic cell
				}
			}
		}
	}
}

#if DEBUG
struct HomeViewTopicPerformanceList_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewTopicPerformanceList()
			.environmentObject(CurrentStore(user: .init(
				id: "0",
				name: "Ken Mueller",
				email: "kenmueller0@gmail.com",
				interests: [],
				numberOfDecks: 0
			)))
	}
}
#endif

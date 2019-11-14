import SwiftUI

struct HomeViewTopicPerformanceList: View {
	static let cellDimension: CGFloat = 72
	
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack {
				ForEach(currentStore.interests, id: \.self) { topic in
					Group {
						if topic == nil {
							LoadingTopicCell(
								dimension: Self.cellDimension
							)
						} else {
							BasicTopicCell(
								topic: topic!,
								dimension: Self.cellDimension
							)
						}
					}
				}
			}
			.padding(.leading)
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

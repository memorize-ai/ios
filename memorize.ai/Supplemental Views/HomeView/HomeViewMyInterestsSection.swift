import SwiftUI

struct HomeViewMyInterestsSection: View {
	@ObservedObject var currentUser: User
	
	var body: some View {
		VStack {
			if !self.currentUser.interests.isEmpty {
				CustomRectangle(
					background: Color.lightGrayBackground.opacity(0.5)
				) {
					Text("My interests")
						.font(.muli(.bold, size: 20))
						.foregroundColor(.darkGray)
						.padding(.horizontal, 8)
						.padding(.vertical, 4)
				}
				.align(to: .leading)
				.padding(.horizontal, 23)
			}
			HomeViewTopicPerformanceList()
		}
	}
}

#if DEBUG
struct HomeViewMyInterestsSection_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewMyInterestsSection(
			currentUser: PREVIEW_CURRENT_STORE.user
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

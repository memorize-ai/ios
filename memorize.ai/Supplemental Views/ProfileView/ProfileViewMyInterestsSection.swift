import SwiftUI

struct ProfileViewMyInterestsSection: View {
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
			// TODO: Show topics
		}
		.padding(.top)
		.onAppear {
			// TODO: Load all topics
		}
	}
}

#if DEBUG
struct ProfileViewMyInterestsSection_Previews: PreviewProvider {
	static var previews: some View {
		ProfileViewMyInterestsSection(
			user: PREVIEW_CURRENT_STORE.user
		)
	}
}
#endif

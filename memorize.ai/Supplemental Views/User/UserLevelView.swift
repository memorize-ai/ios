import SwiftUI

struct UserLevelView: View {
	@ObservedObject var user: User
	
	var body: some View {
		VStack(alignment: .leading) {
			HStack(spacing: 6) {
				Text("lvl \(user.level.formatted)")
					.font(.muli(.extraBold, size: 13))
					.foregroundColor(.extraPurple)
				Circle()
					.foregroundColor(.lightGrayText)
					.frame(width: 4, height: 4)
				Text("\(user.xp.formatted) xp")
					.font(.muli(.bold, size: 13))
					.foregroundColor(.lightGrayText)
			}
			HStack {
				UserLevelSlider()
				Text("lvl \((user.level + 1).formatted)")
					.font(.muli(.bold, size: 13))
					.foregroundColor(.darkGray)
			}
		}
	}
}

#if DEBUG
struct UserLevelView_Previews: PreviewProvider {
	static var previews: some View {
		UserLevelView(
			user: PREVIEW_CURRENT_STORE.user
		)
	}
}
#endif

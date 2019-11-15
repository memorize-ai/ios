import SwiftUI

struct FloatingReviewButton: View {
	@ObservedObject var user: User
	
	var body: some View {
		Text(String(user.numberOfDueCards))
	}
}

#if DEBUG
struct FloatingReviewButton_Previews: PreviewProvider {
	static var previews: some View {
		FloatingReviewButton(
			user: PREVIEW_CURRENT_STORE.user
		)
	}
}
#endif

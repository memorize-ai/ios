import SwiftUI

struct FloatingReviewButton: View {
	@ObservedObject var user: User
	
	var body: some View {
		Button(action: {
			// TODO: Review all cards
		}) {
			ZStack {
				Circle()
					.foregroundColor(.neonGreen)
					.overlay(
						Circle()
							.stroke(Color.lightGray)
					)
					.shadow(
						color: Color.black.opacity(0.3),
						radius: 10,
						y: 5
					)
					.frame(width: 64, height: 64)
				Text(String(user.numberOfDueCards)) // TODO: Add styling
			}
		}
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

import SwiftUI

struct FloatingReviewButton: View {
	@ObservedObject var user: User
	
	var color: Color {
		let count = user.numberOfDueCards
		if count < 10 { return .neonGreen }
		if count < 100 { return .neonOrange }
		return .neonRed
	}
	
	var numberOfDueCardsText: some View {
		Text(user.numberOfDueCards.formatted)
			.font(.muli(.regular, size: 12))
			.foregroundColor(color)
			.shrinks()
	}
	
	var body: some View {
		ReviewViewNavigationLink {
			ZStack {
				Circle()
					.foregroundColor(color)
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
				DeckIcon {
					self.numberOfDueCardsText
				}
				.scaleEffect(1.2)
			}
			.opacity(0.75)
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

import SwiftUI

struct CramViewSliders: View {
	let numberOfTotalCards: Int
	let numberOfMasteredCards: Int
	let numberOfSeenCards: Int
	let numberOfUnseenCards: Int
	
	func title(_ text: String, isEnabled: Bool) -> some View {
		Text(text)
			.font(.muli(.bold, size: 14))
			.foregroundColor(
				Color.white.opacity(isEnabled ? 1 : 0.36)
			)
	}
	
	func slider(percent: CGFloat) -> some View {
		ZStack {
			Capsule()
				.foregroundColor(Color.white.opacity(0.36))
			Capsule()
				.foregroundColor(.white)
				.scaleEffect(
					x: percent,
					y: 1,
					anchor: .leading
				)
				.cornerRadius(2)
		}
		.frame(height: 4)
	}
	
	var body: some View {
		HStack {
			VStack(alignment: .trailing, spacing: 4) {
				title(
					"Mastered",
					isEnabled: numberOfMasteredCards > 0
				)
				title(
					"Seen",
					isEnabled: numberOfSeenCards > 0
				)
				title(
					"Unseen",
					isEnabled: numberOfUnseenCards > 0
				)
			}
			VStack(spacing: 17.75) {
				slider(percent:
					.init(numberOfMasteredCards) &/
					.init(numberOfTotalCards)
				)
				slider(percent:
					.init(numberOfSeenCards) &/
					.init(numberOfTotalCards)
				)
				slider(percent:
					.init(numberOfUnseenCards) &/
					.init(numberOfTotalCards)
				)
			}
			.offset(y: 1)
		}
		.animation(.easeIn(duration: 0.3))
	}
}

#if DEBUG
struct CramViewSliders_Previews: PreviewProvider {
	static var previews: some View {
		CramViewSliders(
			numberOfTotalCards: 3,
			numberOfMasteredCards: 1,
			numberOfSeenCards: 1,
			numberOfUnseenCards: 1
		)
	}
}
#endif

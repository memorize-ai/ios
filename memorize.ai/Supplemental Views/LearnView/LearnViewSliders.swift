import SwiftUI

struct LearnViewSliders: View {
	@EnvironmentObject var model: LearnViewModel
	
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
					isEnabled: model.numberOfMasteredCards > 0
				)
				title(
					"Seen",
					isEnabled: model.numberOfSeenCards > 0
				)
				title(
					"Unseen",
					isEnabled: model.numberOfUnseenCards > 0
				)
			}
			VStack(spacing: 17.75) {
				slider(percent:
					.init(model.numberOfMasteredCards) &/
					.init(model.numberOfTotalCards)
				)
				slider(percent:
					.init(model.numberOfSeenCards) &/
					.init(model.numberOfTotalCards)
				)
				slider(percent:
					.init(model.numberOfUnseenCards) &/
					.init(model.numberOfTotalCards)
				)
			}
			.offset(y: 1)
		}
	}
}

#if DEBUG
struct LearnViewSliders_Previews: PreviewProvider {
	static var previews: some View {
		LearnViewSliders()
			.environmentObject(LearnViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil
			))
	}
}
#endif

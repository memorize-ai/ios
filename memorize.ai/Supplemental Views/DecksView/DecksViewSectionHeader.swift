import SwiftUI

struct DecksViewSectionHeader: View {
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var deck: Deck
	
	@ObservedObject var section: Deck.Section
	
	var isLocked: Bool {
		!(deck.userData?.unlockedSections.contains(section.id) ?? false)
	}
	
	var cardCountMessage: String {
		"(\(section.numberOfCards.formatted) card\(section.numberOfCards == 1 ? "" : "s"))"
	}
	
	var minusIcon: some View {
		Capsule()
			.foregroundColor(.darkBlue)
			.frame(height: 2)
	}
	
	var plusIcon: some View {
		ZStack {
			minusIcon
			minusIcon
				.rotationEffect(.degrees(90))
		}
	}
	
	var body: some View {
		HStack(spacing: 12) {
			if isLocked {
				Image.lock
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 16)
			}
			Text(section.name)
				.font(.muli(.bold, size: 17))
			Rectangle()
				.foregroundColor(.lightGrayBorder)
				.frame(height: 1)
			Text(cardCountMessage)
				.font(.muli(.bold, size: 15))
				.foregroundColor(.darkBlue)
			Button(action: {
				self.model.toggleSectionExpanded(self.section)
			}) {
				ZStack {
					Circle()
						.stroke(Color.lightGrayBorder)
					Group {
						if model.isSectionExpanded(section) {
							minusIcon
						} else {
							plusIcon
						}
					}
					.padding(5)
				}
				.frame(width: 21, height: 21)
			}
		}
	}
}

#if DEBUG
struct DecksViewSectionHeader_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewSectionHeader(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			section: .init(
				id: "0",
				name: "CSS",
				numberOfCards: 56
			)
		)
		.padding(.horizontal, DecksView.horizontalPadding)
		.environmentObject(DecksViewModel())
	}
}
#endif

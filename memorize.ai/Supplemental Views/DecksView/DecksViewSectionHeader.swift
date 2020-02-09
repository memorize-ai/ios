import SwiftUI

struct DecksViewSectionHeader: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var section: Deck.Section
	
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
			if !section.isUnlocked {
				Button(action: {
					self.section.showUnlockAlert(
						forUser: self.currentStore.user
					)
				}) {
					Image.lock
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 16, height: 21)
				}
			}
			Text(section.name)
				.font(.muli(.bold, size: 17))
				.layoutPriority(1)
			Rectangle()
				.foregroundColor(.lightGrayBorder)
				.frame(height: 1)
			Text(cardCountMessage)
				.font(.muli(.bold, size: 15))
				.foregroundColor(.darkBlue)
			HStack(spacing: 4) {
				Button(action: {
					self.model.toggleSectionExpanded(
						self.section,
						forUser: self.currentStore.user
					)
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
				VerticalTripleDots(color: .darkBlue) {
					popUpWithAnimation {
						self.model.selectedSection = self.section
						self.model.isSectionOptionsPopUpShowing = true
					}
				}
				.padding(.horizontal, 12)
			}
		}
		.padding(.trailing, -12)
	}
}

#if DEBUG
struct DecksViewSectionHeader_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewSectionHeader(section: .init(
			id: "0",
			parent: PREVIEW_CURRENT_STORE.user.decks.first!,
			name: "CSS",
			index: 0,
			numberOfCards: 56
		))
		.padding(.horizontal, DecksView.horizontalPadding)
		.environmentObject(PREVIEW_CURRENT_STORE)
		.environmentObject(DecksViewModel())
	}
}
#endif

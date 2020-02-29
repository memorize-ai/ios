import SwiftUI

struct DecksViewSectionHeader: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var section: Deck.Section
	
	@Binding var selectedSection: Deck.Section?
	@Binding var isSectionOptionsPopUpShowing: Bool
	
	let isSectionExpanded: (Deck.Section) -> Bool
	let toggleSectionExpanded: (Deck.Section, User) -> Void
	
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
				.lineLimit(1)
				.layoutPriority(1)
			HStack(spacing: 4) {
				Button(action: {
					self.toggleSectionExpanded(
						self.section,
						self.currentStore.user
					)
				}) {
					ZStack {
						Circle()
							.stroke(Color.lightGrayBorder)
						Group {
							if isSectionExpanded(section) {
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
						self.selectedSection = self.section
						self.isSectionOptionsPopUpShowing = true
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
		let section = Deck.Section(
			id: "0",
			parent: PREVIEW_CURRENT_STORE.user.decks.first!,
			name: "CSS CSS CSS CSS CSS CSS",
			index: 0,
			numberOfCards: 56
		)
		return DecksViewSectionHeader(
			section: section,
			selectedSection: .constant(nil),
			isSectionOptionsPopUpShowing: .constant(false),
			isSectionExpanded: { _ in true },
			toggleSectionExpanded: { _, _ in }
		)
		.padding(.horizontal, DecksView.horizontalPadding)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

import SwiftUI

struct EditCardViewAddSectionPopUp: View {
	@EnvironmentObject var model: EditCardViewModel
	
	@ObservedObject var deck: Deck
	@ObservedObject var card: Card.Draft
	
	let geometry: GeometryProxy
	
	var contentHeight: CGFloat {
		.init(40 + 20 * 2) +
		.init(22 + 12 * 2 + 1) *
		.init(deck.sections.count + 1) -
		1
	}
	
	var sectionList: some View {
		ForEach(deck.sections) { section in
			VStack(spacing: 0) {
				AddCardsViewAddSectionPopUpSectionRow(
					section: section,
					card: self.card
				)
				if section != self.deck.sections.last {
					PopUpDivider(horizontalPadding: 20)
				}
			}
		}
	}
	
	var content: some View {
		Group {
			Button(action: {
				self.card.section = nil
			}) {
				HStack(spacing: 20) {
					if card.sectionId == nil {
						Image.blueCheck
							.resizable()
							.renderingMode(.original)
							.aspectRatio(contentMode: .fit)
							.frame(width: 20)
					}
					Text("Unsectioned")
						.font(.muli(.semiBold, size: 17))
						.foregroundColor(
							card.sectionId == nil
								? .darkBlue
								: .darkGray
						)
					Spacer()
					Text("(\(deck.numberOfUnsectionedCards.formatted))")
						.font(.muli(.semiBold, size: 17))
						.foregroundColor(.darkGray)
				}
				.frame(height: 22)
				.padding(.leading, 25)
				.padding(.trailing, 30)
				.padding(.vertical, 12)
			}
			if !deck.sections.isEmpty {
				PopUpDivider(horizontalPadding: 20)
			}
			sectionList
		}
	}
	
	var body: some View {
		PopUp(
			isShowing: self.$model.isAddSectionPopUpShowing,
			contentHeight: contentHeight,
			geometry: geometry
		) {
			Button(action: {
				self.deck.showCreateSectionAlert { sectionId in
					self.card.section = self.deck.section(withId: sectionId)
				}
			}) {
				CustomRectangle(background: Color.mediumGray) {
					HStack(spacing: 3) {
						if deck.createSectionLoadingState.isLoading {
							ActivityIndicator(color: .darkBlue)
						} else {
							Image(systemName: .plus)
								.font(Font.title.weight(.semibold))
								.scaleEffect(0.65)
							Text("ADD NEW SECTION")
								.font(.muli(.bold, size: 16))
						}
					}
					.foregroundColor(.darkBlue)
					.frame(maxWidth: .infinity)
					.frame(height: 40)
				}
				.padding(.horizontal, 30)
				.padding(.vertical)
			}
			TryLazyVStack(spacing: 0) { self.content }
		}
	}
}

#if DEBUG
struct EditCardViewAddSectionPopUp_Previews: PreviewProvider {
	static var previews: some View {
		let model = EditCardViewModel()
		model.isAddSectionPopUpShowing = true
		return GeometryReader { geometry in
			EditCardViewAddSectionPopUp(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				card: .init(
					parent: PREVIEW_CURRENT_STORE.user.decks.first!
				),
				geometry: geometry
			)
			.environmentObject(model)
		}
	}
}
#endif

import SwiftUI

struct AddCardsViewAddSectionPopUp: View {
	@EnvironmentObject var model: AddCardsViewModel
	
	@ObservedObject var deck: Deck
	@ObservedObject var card: Card.Draft
	
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
	
	var body: some View {
		PopUp(
			isShowing: self.$model.isAddSectionPopUpShowing,
			contentHeight: contentHeight
		) {
			Button(action: {
				// TODO: <1> Add new section
			}) {
				CustomRectangle(background: Color.mediumGray) {
					HStack(spacing: 3) {
						Image(systemName: .plus)
							.font(Font.title.weight(.semibold))
							.scaleEffect(0.65)
						Text("ADD NEW SECTION")
							.font(.muli(.bold, size: 16))
					}
					.foregroundColor(.darkBlue)
					.frame(maxWidth: .infinity)
					.frame(height: 40)
				}
				.padding(.horizontal, 30)
				.padding(.vertical)
			}
			VStack(spacing: 0) {
				Button(action: {
					self.card.sectionId = nil
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
	}
}

#if DEBUG
struct AddCardsViewAddSectionPopUp_Previews: PreviewProvider {
	static var previews: some View {
		let model = AddCardsViewModel(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			user: PREVIEW_CURRENT_STORE.user
		)
		model.isAddSectionPopUpShowing = true
		return AddCardsViewAddSectionPopUp(
			deck: PREVIEW_CURRENT_STORE.user.decks[0],
			card: .init(
				parent: PREVIEW_CURRENT_STORE.user.decks[0],
				card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0]
			)
		)
		.environmentObject(model)
	}
}
#endif

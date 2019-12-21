import SwiftUI

struct AddCardsViewAddSectionPopUp: View {
	static let contentFullHeightRatio: CGFloat = 424 / 667
	static let contentHeight = SCREEN_SIZE.height * contentFullHeightRatio
	
	@EnvironmentObject var model: AddCardsViewModel
	
	@ObservedObject var deck: Deck
	@ObservedObject var card: Card.Draft
	
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
			contentHeight: 50 * 0 + 0
		) {
			CustomRectangle(
				background: Color.mediumGray
			) {
				HStack(spacing: 3) {
					Image(systemName: .plus)
						.font(Font.title.weight(.semibold))
						.scaleEffect(0.65)
					Text("ADD NEW SECTION")
						.font(.muli(.bold, size: 16))
				}
				.foregroundColor(.darkBlue)
				.padding(.leading, 12)
				.padding(.trailing)
				.padding(.vertical, 10)
				.frame(maxWidth: .infinity)
			}
			.padding(.horizontal, 30)
			.padding(.vertical)
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
						Text("(\(section.numberOfCards.formatted))")
							.font(.muli(.semiBold, size: 17))
							.foregroundColor(.darkGray)
					}
					.padding(.leading, 25)
					.padding(.trailing, 30)
					.padding(.vertical, 12)
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

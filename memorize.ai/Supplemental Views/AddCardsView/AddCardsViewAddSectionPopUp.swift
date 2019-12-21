import SwiftUI

struct AddCardsViewAddSectionPopUp: View {
	static let contentFullHeightRatio: CGFloat = 424 / 667
	static let contentHeight = SCREEN_SIZE.height * contentFullHeightRatio
	
	@EnvironmentObject var model: AddCardsViewModel
	
	@ObservedObject var deck: Deck
	
	var sectionList: some View {
		ForEach(deck.sections) { section in
			VStack(spacing: 0) {
				AddCardsViewAddSectionPopUpSectionRow(
					section: section
				)
				if section == self.deck.sections.last {
					PopUpDivider()
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
			// TODO: Add unsectioned
			sectionList
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
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
		.environmentObject(model)
	}
}
#endif

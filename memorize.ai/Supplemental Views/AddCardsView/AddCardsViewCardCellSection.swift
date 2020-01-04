import SwiftUI

struct AddCardsViewCardCellSection: View {
	@EnvironmentObject var model: AddCardsViewModel
	
	@ObservedObject var card: Card.Draft
	
	var isLoading: Bool {
		card.sectionId != nil && card.section == nil
	}
	
	var title: String {
		card.section?.name ?? "Unsectioned"
	}
	
	var body: some View {
		Button(action: {
			self.model.currentCard = self.card
			popUpWithAnimation {
				self.model.isAddSectionPopUpShowing = true
			}
		}) {
			CustomRectangle(
				background: Color.mediumGray.opacity(0.68)
			) {
				HStack {
					if isLoading {
						ActivityIndicator(color: .lightGrayText)
					} else {
						Text(title)
							.font(.muli(.regular, size: 18))
							.foregroundColor(.lightGrayText)
					}
					Spacer()
					Image.grayDropDownArrowHead
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 20)
						.padding(.vertical)
				}
				.padding(.horizontal)
			}
		}
	}
}

#if DEBUG
struct AddCardsViewCardCellSection_Previews: PreviewProvider {
	static var previews: some View {
		AddCardsViewCardCellSection(card: .init(
			parent: PREVIEW_CURRENT_STORE.user.decks.first!
		))
		.environmentObject(AddCardsViewModel(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			user: PREVIEW_CURRENT_STORE.user
		))
	}
}
#endif

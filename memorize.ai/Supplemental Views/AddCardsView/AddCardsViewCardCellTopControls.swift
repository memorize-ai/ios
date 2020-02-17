import SwiftUI

struct AddCardsViewCardCellTopControls: View {
	@EnvironmentObject var model: AddCardsViewModel
	
	@ObservedObject var card: Card.Draft
	
	var body: some View {
		HStack {
			Text(Card.stripFormatting(card.front).defaultIfEmpty("New card"))
				.font(.muli(.bold, size: 15))
				.foregroundColor(.white)
				.lineLimit(1)
			Spacer()
			if card.publishLoadingState.isLoading {
				ActivityIndicator(color: .white)
			} else {
				Button(action: {
					self.model.removeCard(self.card)
				}) {
					Image.whiteTrashIcon
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(height: 17)
				}
			}
		}
	}
}

#if DEBUG
struct AddCardsViewCardCellTopControls_Previews: PreviewProvider {
	static var previews: some View {
		AddCardsViewCardCellTopControls(card: .init(
			parent: PREVIEW_CURRENT_STORE.user.decks.first!
		))
		.environmentObject(AddCardsViewModel(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			user: PREVIEW_CURRENT_STORE.user
		))
	}
}
#endif

import SwiftUI

struct EditCardViewCardCellTopControls: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var card: Card.Draft
	
	var user: User {
		currentStore.user
	}
	
	var body: some View {
		HStack {
			Text(Card.stripFormatting(card.front).defaultIfEmpty("Empty"))
				.font(.muli(.bold, size: 15))
				.foregroundColor(.white)
				.lineLimit(1)
			Spacer()
			if card.publishLoadingState.isLoading {
				ActivityIndicator(color: .white)
			} else {
				Button(action: {
					self.card.showDeleteAlert(forUser: self.user) {
						self.presentationMode.wrappedValue.dismiss()
					}
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
struct EditCardViewCardCellTopControls_Previews: PreviewProvider {
	static var previews: some View {
		EditCardViewCardCellTopControls(card: .init(
			parent: PREVIEW_CURRENT_STORE.user.decks.first!
		))
	}
}
#endif

import SwiftUI

struct EditCardViewCardCell: View {
	let card: Card.Draft
	
	func headerText(_ text: String) -> some View {
		Text(text)
			.font(.muli(.bold, size: 15))
			.alignment(.leading)
			.padding(.top, 2)
	}
	
	var body: some View {
		VStack(spacing: 8) {
			EditCardViewCardCellTopControls(card: card)
				.padding(.horizontal, 6)
			CustomRectangle(background: Color.white) {
				VStack {
					EditCardViewCardCellSection(card: card)
					Rectangle()
						.foregroundColor(.lightGrayBorder)
						.frame(height: 1)
					headerText("FRONT")
					CKEditor(
						html: .init(
							get: { self.card.front },
							set: { self.card.front = $0 }
						),
						deckId: card.parent.id,
						width: SCREEN_SIZE.width - 10 * 2 - 20 * 2
					)
					headerText("BACK")
					CKEditor(
						html: .init(
							get: { self.card.back },
							set: { self.card.back = $0 }
						),
						deckId: card.parent.id,
						width: SCREEN_SIZE.width - 10 * 2 - 20 * 2
					)
				}
				.padding()
			}
		}
	}
}

#if DEBUG
struct EditCardViewCardCell_Previews: PreviewProvider {
	static var previews: some View {
		EditCardViewCardCell(card: .init(
			parent: PREVIEW_CURRENT_STORE.user.decks.first!
		))
		.environmentObject(EditCardViewModel())
	}
}
#endif

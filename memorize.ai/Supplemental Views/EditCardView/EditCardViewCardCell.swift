import SwiftUI

struct EditCardViewCardCell: View {
	let card: Card.Draft
	
	func headerText(_ text: String) -> some View {
		Text(text)
			.font(.muli(.bold, size: 15))
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.top, 2)
	}
	
	func editor(html: Binding<String>) -> some View {
		CustomRectangle(
			background: Color.white,
			borderColor: Color.gray.opacity(0.2),
			borderWidth: 1
		) {
			FroalaEditor(html: html)
				.frame(height: 200)
		}
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
					editor(html: .init(
						get: { self.card.front },
						set: { self.card.front = $0 }
					))
					headerText("BACK")
					editor(html: .init(
						get: { self.card.back },
						set: { self.card.back = $0 }
					))
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

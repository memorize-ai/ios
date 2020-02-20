import SwiftUI

struct EditCardViewCardCell: View {
	static let editorWidth = SCREEN_SIZE.width - 7 * 2 - 20 * 2
	
	@ObservedObject var card: Card.Draft
	
	@State var isFrontExpanded = false
	@State var isBackExpanded = false
	
	func editorHeader(text: String, isValid: Bool) -> some View {
		HStack {
			Text(text)
				.foregroundColor(.darkGray)
			Image(systemName: isValid ? .checkmark : .xmark)
				.foregroundColor(isValid ? .neonGreen : .darkRed)
			Spacer()
		}
		.font(.muli(.bold, size: 15))
		.padding(.top, 3)
		.padding(.bottom, -5)
	}
	
	var body: some View {
		VStack(spacing: 8) {
			EditCardViewCardCellTopControls(card: card)
				.padding(.horizontal, 6)
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGray,
				borderWidth: 1.5,
				cornerRadius: 8,
				shadowRadius: 5
			) {
				VStack {
					Text("Choose section")
						.font(.muli(.bold, size: 15))
						.foregroundColor(.darkGray)
						.alignment(.leading)
						.padding(.vertical, -6)
					EditCardViewCardCellSection(card: card)
					Rectangle()
						.foregroundColor(.lightGrayBorder)
						.frame(height: 1)
					editorHeader(text: "Front", isValid: !card.front.isTrimmedEmpty)
					CKEditor(
						html: $card.front,
						isFocused: $isFrontExpanded,
						deckId: card.parent.id,
						width: Self.editorWidth,
						height: isFrontExpanded ? 500 : 125
					)
					editorHeader(text: "Back", isValid: !card.back.isTrimmedEmpty)
					CKEditor(
						html: $card.back,
						isFocused: $isBackExpanded,
						deckId: card.parent.id,
						width: Self.editorWidth,
						height: isBackExpanded ? 500 : 125
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

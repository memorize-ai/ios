import SwiftUI
import WebView

struct AddCardsViewCardCell: View {
	static let editorWidth = SCREEN_SIZE.width - 7 * 2 - 20 * 2
	
	@EnvironmentObject var model: AddCardsViewModel
	
	@ObservedObject var card: Card.Draft
	
	@State var isFrontExpanded = false
	@State var isBackExpanded = false
	
	func editorHeader(text: String, isValid: Bool, isExpanded: Binding<Bool>) -> some View {
		HStack {
			Text(text)
				.foregroundColor(.darkGray)
			Image(systemName: isValid ? .checkmark : .xmark)
				.foregroundColor(isValid ? .neonGreen : .darkRed)
			Spacer()
			Button(action: {
				isExpanded.wrappedValue.toggle()
			}) {
				Text(isExpanded.wrappedValue ? "Collapse" : "Expand")
			}
		}
		.font(.muli(.bold, size: 15))
		.padding(.top, 3)
		.padding(.bottom, -5)
	}
	
	var body: some View {
		VStack(spacing: 8) {
			AddCardsViewCardCellTopControls(card: card)
				.padding(.horizontal, 6)
			CustomRectangle(background: Color.white) {
				VStack {
					Text("Choose section")
						.font(.muli(.bold, size: 15))
						.foregroundColor(.darkGray)
						.alignment(.leading)
						.padding(.vertical, -6)
					AddCardsViewCardCellSection(card: card)
					Rectangle()
						.foregroundColor(.lightGrayBorder)
						.frame(height: 1)
					editorHeader(text: "Front", isValid: !card.front.isTrimmedEmpty, isExpanded: $isFrontExpanded)
					CKEditor(
						html: $card.front,
						deckId: model.deck.id,
						width: Self.editorWidth,
						height: isFrontExpanded ? 500 : 250
					)
					editorHeader(text: "Back", isValid: !card.back.isTrimmedEmpty, isExpanded: $isBackExpanded)
					CKEditor(
						html: $card.back,
						deckId: model.deck.id,
						width: Self.editorWidth,
						height: isBackExpanded ? 500 : 250
					)
				}
				.padding()
			}
		}
	}
}

#if DEBUG
struct AddCardsViewCardCell_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.blue
				.edgesIgnoringSafeArea(.all)
			AddCardsViewCardCell(card: .init(
				parent: PREVIEW_CURRENT_STORE.user.decks.first!
			))
			.padding(.horizontal, 10)
		}
		.environmentObject(AddCardsViewModel(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			user: PREVIEW_CURRENT_STORE.user
		))
	}
}
#endif

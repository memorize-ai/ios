import SwiftUI
import WebView

struct AddCardsViewCardCell: View {
	@EnvironmentObject var model: AddCardsViewModel
	
	let card: Card.Draft
	
	func headerText(_ text: String) -> some View {
		Text(text)
			.font(.muli(.bold, size: 15))
			.alignment(.leading)
			.padding(.top, 2)
	}
	
	var body: some View {
		VStack(spacing: 8) {
			AddCardsViewCardCellTopControls(card: card)
				.padding(.horizontal, 6)
			CustomRectangle(
				background: Color.white
			) {
				VStack {
					AddCardsViewCardCellSection(card: card)
					Rectangle()
						.foregroundColor(.lightGrayBorder)
						.frame(height: 1)
					headerText("FRONT")
					CKEditor(html: .init(
						get: { self.card.front },
						set: { self.card.front = $0 }
					))
					headerText("BACK")
					CKEditor(html: .init(
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

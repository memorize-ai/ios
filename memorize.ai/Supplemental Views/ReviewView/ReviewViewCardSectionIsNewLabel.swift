import SwiftUI

struct ReviewViewCardSectionIsNewLabel: View {
	@ObservedObject var card: Card.ReviewData
	
	var body: some View {
		Group {
			if card.isNew {
				Text("new")
					.foregroundColor(Color.white.opacity(0.36))
			}
		}
	}
}

#if DEBUG
struct ReviewViewCardSectionIsNewLabel_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewCardSectionIsNewLabel(
			card: .init(
				parent: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0],
				userData: nil
			)
		)
	}
}
#endif

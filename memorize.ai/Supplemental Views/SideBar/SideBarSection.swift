import SwiftUI

struct SideBarSection: View {
	let title: String
	let decks: [Deck]
	
	@Binding var selectedDeck: Deck?
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			SideBarSectionTitle(title)
				.padding(.leading)
			VStack(spacing: 4) {
				ForEach(decks) { deck in
					DeckRow(
						deck: deck,
						selectedDeck: self.$selectedDeck,
						unselectedBackgroundColor: .lightGrayBackground
					)
				}
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

#if DEBUG
struct SideBarSection_Previews: PreviewProvider {
	static var previews: some View {
		SideBarSection(
			title: "Due",
			decks: [],
			selectedDeck: .constant(nil)
		)
	}
}
#endif

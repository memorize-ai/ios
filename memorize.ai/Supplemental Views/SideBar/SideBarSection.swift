import SwiftUI

struct SideBarSection: View {
	let title: String
	let decks: [Deck]
	
	@Binding var selectedDeck: Deck?
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			SideBarSectionTitle(title)
			VStack(spacing: 12) {
				ForEach(decks) { deck in
					SideBarDeckRow(
						deck: deck,
						selectedDeck: self.$selectedDeck
					)
				}
			}
		}
		.padding(.leading)
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

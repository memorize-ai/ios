import SwiftUI

struct SideBarSection: View {
	let title: String
	let decks: [Deck]
		
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			SideBarSectionTitle(title)
				.padding(.leading)
			LazyVStack(spacing: 4) {
				ForEach(decks) { deck in
					DeckRow(
						deck: deck,
						unselectedBackgroundColor: .lightGrayBackground
					)
				}
			}
		}
		.alignment(.leading)
	}
}

#if DEBUG
struct SideBarSection_Previews: PreviewProvider {
	static var previews: some View {
		SideBarSection(
			title: "Due",
			decks: []
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

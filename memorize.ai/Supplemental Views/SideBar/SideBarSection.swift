import SwiftUI

struct SideBarSection: View {
	let title: String
	let decks: [Deck]
	
	var content: some View {
		ForEach(decks) { deck in
			DeckRow(
				deck: deck,
				unselectedBackgroundColor: .lightGrayBackground
			)
		}
	}
		
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			SideBarSectionTitle(title)
				.padding(.leading)
			if #available(iOS 14.0, *) {
				LazyVStack(spacing: 4) { content }
			} else {
				VStack(spacing: 4) { content }
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

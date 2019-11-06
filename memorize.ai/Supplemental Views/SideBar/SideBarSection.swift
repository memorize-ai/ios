import SwiftUI

struct SideBarSection: View {
	let title: String
	let decks: [Deck]
	
	var body: some View {
		VStack {
			SideBarSectionTitle(title)
				.padding(.leading)
			ForEach(decks, content: SideBarDeckRow.init)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

#if DEBUG
struct SideBarSection_Previews: PreviewProvider {
	static var previews: some View {
		SideBarSection(title: "Due", decks: [])
	}
}
#endif

import SwiftUI

struct DecksViewSectionHeader: View {
	@ObservedObject var section: Deck.Section
	
	var body: some View {
		HStack {
			Text(section.name)
			Text(section.numberOfCards.formatted)
		}
		.foregroundColor(.white)
	}
}

#if DEBUG
struct DecksViewSectionHeader_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewSectionHeader(section: .init(
			id: "0",
			name: "CSS",
			numberOfCards: 56
		))
	}
}
#endif

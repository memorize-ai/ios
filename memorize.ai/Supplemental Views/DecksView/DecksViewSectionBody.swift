import SwiftUI

struct DecksViewSectionBody: View {
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var section: Deck.Section
	
	var body: some View {
		Text("DecksViewSectionBody")
	}
}

#if DEBUG
struct DecksViewSectionBody_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewSectionBody(section: .init(
			id: "0",
			parent: PREVIEW_CURRENT_STORE.user.decks.first!,
			name: "CSS",
			numberOfCards: 56
		))
		.padding(.horizontal, DecksView.horizontalPadding)
		.environmentObject(DecksViewModel())
	}
}
#endif

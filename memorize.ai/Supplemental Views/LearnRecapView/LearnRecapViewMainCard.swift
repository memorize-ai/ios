import SwiftUI

struct LearnRecapViewMainCard: View {
	@ObservedObject var deck: Deck
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1.5
		) {
			VStack {
				CustomRectangle(
					background: Color.lightGrayBackground
				) {
					VStack {
						Text("XP")
					}
				}
				.padding([.horizontal, .top], 8)
				Text("Your performance ratings for")
				Text(deck.name)
			}
		}
	}
}

#if DEBUG
struct LearnRecapViewMainCard_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewMainCard(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
	}
}
#endif

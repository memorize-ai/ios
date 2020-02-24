import SwiftUI

struct EditCardView: View {
	let card: Card.Draft
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				Group {
					Color.lightGrayBackground
					HomeViewTopGradient(
						addedHeight: geometry.safeAreaInsets.top
					)
				}
				.edgesIgnoringSafeArea(.all)
				VStack {
					EditCardViewTopControls(card: self.card)
						.padding(.horizontal, 23)
					ScrollView {
						EditCardViewCardCell(card: self.card)
							.padding([.horizontal, .bottom], 10)
							.respondsToKeyboard(
								withExtraOffset: 30 - (15 + geometry.safeAreaInsets.bottom)
							)
					}
				}
				EditCardViewAddSectionPopUp(deck: self.card.parent, card: self.card)
			}
		}
	}
}

#if DEBUG
struct EditCardView_Previews: PreviewProvider {
	static var previews: some View {
		EditCardView(card: .init(
			parent: PREVIEW_CURRENT_STORE.user.decks.first!
		))
		.environmentObject(EditCardViewModel())
	}
}
#endif

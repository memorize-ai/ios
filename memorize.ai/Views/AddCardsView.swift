import SwiftUI

struct AddCardsView: View {
	@EnvironmentObject var model: AddCardsViewModel
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				HomeViewTopGradient(
					addedHeight: geometry.safeAreaInsets.top
				)
				.edgesIgnoringSafeArea(.all)
				VStack {
					AddCardsViewTopControls()
						.padding(.horizontal, 23)
					ScrollView {
						VStack(spacing: 20) {
							ForEach(self.model.cards) { card in
								AddCardsViewCardCell(card: card)
							}
						}
						.padding(.horizontal, 10)
					}
				}
			}
		}
	}
}

#if DEBUG
struct AddCardsView_Previews: PreviewProvider {
	static var previews: some View {
		AddCardsView()
			.environmentObject(AddCardsViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				user: PREVIEW_CURRENT_STORE.user
			))
	}
}
#endif

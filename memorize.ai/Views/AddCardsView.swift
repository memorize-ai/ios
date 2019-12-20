import SwiftUI

struct AddCardsView: View {
	@EnvironmentObject var model: AddCardsViewModel
	
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
					AddCardsViewTopControls()
						.padding(.horizontal, 23)
					VStack(spacing: 0) {
						ScrollView {
							VStack(spacing: 20) {
								ForEach(self.model.cards) { card in
									AddCardsViewCardCell(card: card)
								}
							}
							.padding(.horizontal, 10)
						}
						Button(action: {
							// TODO: Remove draft
						}) {
							VStack(spacing: 0) {
								Rectangle()
									.foregroundColor(.lightGrayLine)
									.frame(height: 1)
								ZStack {
									Color.white
										.edgesIgnoringSafeArea(.all)
									Text("Remove draft")
										.font(.muli(.semiBold, size: 18))
										.foregroundColor(.darkRed)
								}
								.frame(height: 15 + geometry.safeAreaInsets.bottom)
							}
						}
						.edgesIgnoringSafeArea(.all)
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

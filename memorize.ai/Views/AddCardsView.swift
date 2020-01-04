import SwiftUI

struct AddCardsView: View {
	@Environment(\.presentationMode) var presentationMode
	
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
							.padding([.horizontal, .bottom], 10)
							.respondsToKeyboard(
								withExtraOffset: -15 - geometry.safeAreaInsets.bottom
							)
						}
						Button(action: {
							popUpWithAnimation {
								self.model.isRemoveDraftPopUpShowing = true
							}
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
				PopUp(
					isShowing: self.$model.isRemoveDraftPopUpShowing,
					contentHeight: 50 + 1 + 50
				) {
					Text("Are you sure?")
						.font(.muli(.regular, size: 18))
						.frame(maxWidth: .infinity, alignment: .leading)
						.frame(height: 50)
						.padding(.horizontal, 30)
					PopUpDivider()
					PopUpButton(
						icon: Image.redTrashIcon
							.resizable()
							.renderingMode(.original)
							.aspectRatio(contentMode: .fit)
							.frame(width: 21, height: 21),
						text: "Remove",
						textColor: .darkRed
					) {
						self.model.removeAllDrafts()
						self.presentationMode.wrappedValue.dismiss()
					}
				}
				if self.model.currentCard != nil {
					AddCardsViewAddSectionPopUp(
						deck: self.model.deck,
						card: self.model.currentCard!
					)
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

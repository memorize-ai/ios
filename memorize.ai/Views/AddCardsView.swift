import SwiftUI

struct AddCardsView<Destination: View>: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var model: AddCardsViewModel
	
	let destination: Destination?
	
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
					AddCardsViewTopControls(destination: self.destination)
						.padding(.horizontal, 23)
						.padding(.bottom, self.destination == nil ? 0 : 8)
					VStack(spacing: 0) {
						ScrollView {
							VStack(spacing: 20) {
								ForEach(self.model.cards) { card in
									AddCardsViewCardCell(card: card)
								}
								HStack {
									Button(action: self.model.addCard) {
										CustomRectangle(background: Color.white) {
											HStack(spacing: 3) {
												Image(systemName: .plus)
													.font(Font.title.weight(.bold))
													.scaleEffect(0.65)
												Text("Add card")
													.font(.muli(.extraBold, size: 16))
													.shrinks()
											}
											.foregroundColor(.darkBlue)
											.padding(.leading, 12)
											.padding(.trailing)
											.padding(.vertical, 10)
										}
									}
									Button(action: {
										popUpWithAnimation {
											self.model.isRemoveDraftPopUpShowing = true
										}
									}) {
										CustomRectangle(background: Color.white) {
											HStack(spacing: 7) {
												Image.redTrashIcon
													.resizable()
													.renderingMode(.original)
													.aspectRatio(contentMode: .fit)
													.frame(width: 17, height: 17)
												Text("Remove all")
													.font(.muli(.extraBold, size: 16))
													.shrinks()
											}
											.foregroundColor(.darkRed)
											.padding(.leading, 12)
											.padding(.trailing)
											.padding(.vertical, 10)
										}
									}
								}
								.padding(.top, -10)
							}
							.padding([.horizontal, .bottom], 10)
							.frame(maxWidth: .infinity)
							.respondsToKeyboard(
								withExtraOffset: -(15 + geometry.safeAreaInsets.bottom)
							)
						}
					}
				}
				PopUp(
					isShowing: self.$model.isRemoveDraftPopUpShowing,
					contentHeight: 50 + 1 + 50
				) {
					Text("Are you sure?")
						.font(.muli(.regular, size: 18))
						.alignment(.leading)
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
						self.model.cards = self.model.initialCards
						
						popUpWithAnimation {
							self.model.isRemoveDraftPopUpShowing = false
						}
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
		AddCardsView<EmptyView>(destination: nil)
			.environmentObject(AddCardsViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				user: PREVIEW_CURRENT_STORE.user
			))
	}
}
#endif

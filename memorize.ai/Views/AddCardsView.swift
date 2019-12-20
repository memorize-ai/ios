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
							.padding(.horizontal, 10)
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
						.opacity(*self.model.hasDraft)
					}
				}
				PopUp(
					isShowing: self.$model.isRemoveDraftPopUpShowing,
					contentHeight: 50 + 1 + 50
				) {
					Text("Are you sure?")
						.font(.muli(.bold, size: 18))
						.frame(maxWidth: .infinity, alignment: .leading)
						.frame(height: 50)
						.padding(.horizontal, 30)
					PopUpDivider()
					PopUpButton(
						icon: nil as EmptyView?,
						text: "Remove",
						textColor: .darkRed
					) {
						self.model.removeAllDrafts()
						self.presentationMode.wrappedValue.dismiss()
					}
				}
				PopUp(
					isShowing: self.$model.isAddSectionPopUpShowing,
					contentHeight: 50 * 0 + 0
				) {
					// TODO: Move into separate file
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

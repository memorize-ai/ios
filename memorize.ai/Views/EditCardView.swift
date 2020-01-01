import SwiftUI

struct EditCardView: View {
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
					EditCardViewTopControls()
						.padding(.horizontal, 23)
					ScrollView {
						EditCardViewCardCell()
							.padding([.horizontal, .bottom], 10)
							.respondsToKeyboard(
								withExtraOffset: -15 - geometry.safeAreaInsets.bottom
							)
					}
				}
				EditCardViewAddSectionPopUp()
			}
		}
	}
}

#if DEBUG
struct EditCardView_Previews: PreviewProvider {
	static var previews: some View {
		EditCardView()
			.environmentObject(EditCardViewModel())
			.environmentObject(Card.Draft(
				parent: PREVIEW_CURRENT_STORE.user.decks.first!
			))
	}
}
#endif

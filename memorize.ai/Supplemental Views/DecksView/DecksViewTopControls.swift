import SwiftUI

struct DecksViewTopControls: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var selectedDeck: Deck
	
	var body: some View {
		HStack(spacing: 23) {
			ShowSideBarButton {
				HamburgerMenu()
			}
			HStack(spacing: 10) {
				if selectedDeck.hasImage {
					Group {
						if selectedDeck.image == nil {
							Color.white
								.opacity(0.5)
								.frame(width: 40, height: 40)
						} else {
							selectedDeck.displayImage?
								.resizable()
								.aspectRatio(contentMode: .fill)
								.frame(width: 40, height: 40)
								.clipped()
						}
					}
					.cornerRadius(5)
				}
				Text(selectedDeck.name)
					.font(.muli(.bold, size: 17))
					.foregroundColor(.white)
					.lineLimit(1)
				Spacer()
				if currentStore.user.id == selectedDeck.creatorId {
					PublishDeckViewNavigationLink(deck: selectedDeck) {
						Image.whiteEditSectionsIcon
							.resizable()
							.renderingMode(.original)
							.aspectRatio(contentMode: .fit)
							.frame(width: 26, height: 26)
					}
				}
				VerticalTripleDots {
					popUpWithAnimation {
						self.model.isDeckOptionsPopUpShowing = true
					}
				}
				.padding(.leading, 12)
				.padding(.trailing, 23)
			}
		}
		.frame(height: 40)
		.padding(.leading, DecksView.horizontalPadding)
	}
}

#if DEBUG
struct DecksViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewTopControls(
			selectedDeck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
	}
}
#endif

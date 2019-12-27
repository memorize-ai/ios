import SwiftUI

struct DecksViewTopControls: View {
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
				VerticalTripleDots {
					popUpWithAnimation {
						self.model.isDeckOptionsPopUpShowing = true
					}
				}
			}
		}
		.frame(height: 40)
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

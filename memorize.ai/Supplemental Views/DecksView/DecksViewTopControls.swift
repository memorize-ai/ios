import SwiftUI

struct DecksViewTopControls: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: DecksViewModel
	
	var selectedDeck: Deck {
		currentStore.selectedDeck!
	}
	
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
							selectedDeck.image!
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
				Spacer()
				VerticalTripleDots {
					popUpWithAnimation {
						self.model.isDeckOptionsPopUpShowing = true
					}
				}
			}
		}
	}
}

#if DEBUG
struct DecksViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewTopControls()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

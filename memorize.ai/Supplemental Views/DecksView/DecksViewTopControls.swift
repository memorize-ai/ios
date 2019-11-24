import SwiftUI

struct DecksViewTopControls: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		HStack(spacing: 23) {
			ShowSideBarButton {
				HamburgerMenu()
			}
			HStack(spacing: 10) {
				if currentStore.selectedDeck!.hasImage {
					Group {
						if currentStore.selectedDeck!.image == nil {
							Color.white
								.opacity(0.5)
								.frame(width: 40, height: 40)
						} else {
							currentStore.selectedDeck!.image!
								.resizable()
								.aspectRatio(contentMode: .fill)
								.frame(width: 40, height: 40)
								.clipped()
						}
					}
					.cornerRadius(5)
				}
				Text(currentStore.selectedDeck!.name)
					.font(.muli(.bold, size: 17))
					.foregroundColor(.white)
			}
			Spacer()
			VerticalTripleDots {
				// TODO: Show options pop-up
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

import SwiftUI

struct DecksViewTopControls: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		HStack(spacing: 23) {
			ShowSideBarButton {
				HamburgerMenu()
			}
			if currentStore.selectedDeck == nil {
				Rectangle()
					.foregroundColor(Color.white.opacity(0.5))
					.cornerRadius(5)
					.frame(width: 40, height: 40)
			}
			Spacer()
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

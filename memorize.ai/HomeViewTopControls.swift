import SwiftUI

struct HomeViewTopControls: View {
	static var searchBarBackgroundColor =
		Color.lightGray.opacity(0.2)
	
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		HStack(spacing: 20) {
			ShowSideBarButton {
				HamburgerMenu()
			}
			Button(action: {
				self.currentStore.mainTabViewSelection = .market
			}) {
				CustomRectangle(
					background: Self.searchBarBackgroundColor,
					cornerRadius: 24
				) {
					HStack(spacing: 10) {
						Image.whiteMagnifyingGlass
							.resizable()
							.renderingMode(.original)
							.aspectRatio(contentMode: .fit)
							.frame(width: 14)
						Text("Anything")
							.font(.muli(.regular, size: 17))
							.foregroundColor(.white)
						Spacer()
					}
					.padding(.horizontal)
					.frame(height: 48)
				}
			}
		}
	}
}

#if DEBUG
struct HomeViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewTopControls()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

import SwiftUI

struct HomeViewTopControls: View {
	static var searchBarBackgroundColor =
		Color.lightGray.opacity(0.2)
	
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		ZStack {
			ShowSideBarButton {
				HamburgerMenu()
			}
			.alignment(.leading)
			PublishDeckViewNavigationLink {
				CustomRectangle(background: Color.white) {
					HStack(spacing: 3) {
						Image(systemName: .plus)
							.font(Font.title.weight(.bold))
							.scaleEffect(0.65)
						Text("CREATE DECK")
							.font(.muli(.extraBold, size: 16))
					}
					.foregroundColor(.darkBlue)
					.padding(.leading, 12)
					.padding(.trailing)
					.padding(.vertical, 10)
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

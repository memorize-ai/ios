import SwiftUI

struct HomeViewTopControls: View {
	@Binding var isSideBarShowing: Bool
	
	var searchBarBackgroundColor: Color {
		Color.lightGray.opacity(0.2)
	}
	
	var body: some View {
		HStack(spacing: 20) {
			ShowSideBarButton($isSideBarShowing) {
				HamburgerMenu()
			}
			CustomRectangle(
				background: searchBarBackgroundColor,
				cornerRadius: 24
			) {
				HStack {
					Image.whiteMagnifyingGlass
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 14, height: 14)
					Text("Anything")
						.font(.muli(.regular, size: 17))
						.foregroundColor(.white)
					Spacer()
				}
				.padding(.horizontal)
				.frame(height: 48)
			}
		}
		.padding(.horizontal, 23)
		.padding(.top)
	}
}

#if DEBUG
struct HomeViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewTopControls(isSideBarShowing: .constant(false))
	}
}
#endif

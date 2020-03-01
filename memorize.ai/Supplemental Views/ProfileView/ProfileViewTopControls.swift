import SwiftUI

struct ProfileViewTopControls: View {
	var body: some View {
		HStack {
			HStack(spacing: 23) {
				ShowSideBarButton {
					HamburgerMenu()
				}
				Text("Profile")
					.font(.muli(.bold, size: 20))
					.foregroundColor(.white)
					.alignment(.leading)
			}
			Spacer()
			SignOutButton {
				CustomRectangle(background: Color(#colorLiteral(red: 0.9607843137, green: 0.3647058824, blue: 0.137254902, alpha: 1))) {
					Text("Sign out")
						.font(.muli(.bold, size: 17))
						.foregroundColor(.white)
						.padding(.horizontal, 10)
						.padding(.vertical, 4)
				}
			}
		}
	}
}

#if DEBUG
struct ProfileViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		ProfileViewTopControls()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

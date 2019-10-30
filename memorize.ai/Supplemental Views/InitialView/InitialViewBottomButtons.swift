import SwiftUI

struct InitialViewBottomButtons: View {
	var body: some View {
		HStack(spacing: 16) {
			NavigationLink(destination: SignUpView()) {
				CustomRectangle(background: Color.white) {
					Text("SIGN UP")
						.font(.muli(.bold, size: 14))
						.foregroundColor(.darkBlue)
						.frame(maxWidth: 300)
						.frame(height: 40)
				}
			}
			NavigationLink(destination: LogInView()) {
				CustomRectangle(
					background: Color.transparent,
					borderColor: Color.white.opacity(0.4),
					borderWidth: 2
				) {
					Text("LOG IN")
						.font(.muli(.bold, size: 14))
						.foregroundColor(.white)
						.frame(maxWidth: 300)
						.frame(height: 40)
				}
			}
		}
		.padding(.horizontal, 48)
		.padding(.bottom, 29.64)
	}
}

#if DEBUG
struct InitialViewBottomButtons_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewBottomButtons()
	}
}
#endif

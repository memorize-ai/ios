import SwiftUI

struct InitialViewBottomButtons: View {
	var body: some View {
		HStack(spacing: 16) {
			CustomRectangle {
				Text("SIGN UP")
					.font(.muli(.bold, size: 14))
					.foregroundColor(.darkBlue)
					.frame(maxWidth: 300, maxHeight: 40)
			}
			CustomRectangle(
				backgroundColor: .transparent,
				borderColor: Color.white.opacity(0.4),
				borderWidth: 2
			) {
				Text("LOGIN")
					.font(.muli(.bold, size: 14))
					.foregroundColor(.white)
					.frame(maxWidth: 300, maxHeight: 40)
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

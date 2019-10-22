import SwiftUI

struct InitialView: View {
	var body: some View {
		VStack {
			Spacer()
			HStack(spacing: 16) {
				CustomRectangle {
					Text("SIGN UP")
						.frame(maxWidth: 200, maxHeight: 40)
						.font(.muli(.bold, size: 14))
						.foregroundColor(.darkBlue)
				}
				CustomRectangle(
					backgroundColor: .transparent,
					borderColor: Color.gray.opacity(0.5),
					borderWidth: 1.5
				) {
					Text("LOGIN")
						.frame(maxWidth: 200, maxHeight: 40)
						.font(.muli(.bold, size: 14))
						.foregroundColor(.white)
				}
			}
			.padding(.horizontal, 48)
			.padding(.bottom, 29.64)
			.frame(maxWidth: .infinity)
			.background(Color.green)
		}
	}
}

#if DEBUG
struct InitialView_Previews: PreviewProvider {
	static var previews: some View {
		InitialView()
	}
}
#endif

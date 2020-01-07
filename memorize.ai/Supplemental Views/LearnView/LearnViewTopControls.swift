import SwiftUI

struct LearnViewTopControls: View {
	@Environment(\.presentationMode) var presentationMode
	
	var title: String {
		"1 / 50" // TODO: Change this
	}
	
	var body: some View {
		HStack(spacing: 22) {
			Button(action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
				XButton(.transparentWhite, height: 18)
			}
			Text(title)
				.font(.muli(.bold, size: 20))
				.foregroundColor(.white)
			Spacer()
			Button(action: {
				// TODO: Skip card
			}) {
				CustomRectangle(
					background: Color.transparent,
					borderColor: .transparentLightGray,
					borderWidth: 1.5
				) {
					Text("SKIP")
						.font(.muli(.bold, size: 17))
						.foregroundColor(Color.white.opacity(0.7))
						.padding(.horizontal, 10)
						.frame(height: 30)
				}
			}
		}
	}
}

#if DEBUG
struct LearnViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		LearnViewTopControls()
	}
}
#endif

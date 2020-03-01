import SwiftUI

struct ReviewViewTopControls<RecapView: View>: View {
	@Environment(\.presentationMode) var presentationMode
	
	let currentIndex: Int
	let numberOfTotalCards: Int
	let recapView: () -> RecapView
	
	var title: String {
		"\(currentIndex + 1) / \(numberOfTotalCards)"
	}
	
	func button(text: String) -> some View {
		CustomRectangle(
			background: Color.transparent,
			borderColor: .transparentLightGray,
			borderWidth: 1.5
		) {
			Text(text)
				.font(.muli(.bold, size: 17))
				.foregroundColor(Color.white.opacity(0.7))
				.padding(.horizontal, 10)
				.frame(height: 30)
		}
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
			NavigationLink(
				destination: LazyView(content: recapView)
			) {
				button(text: "RECAP")
			}
		}
	}
}

#if DEBUG
struct ReviewViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewTopControls(
			currentIndex: 0,
			numberOfTotalCards: 3,
			recapView: { Text("Recap view") }
		)
	}
}
#endif

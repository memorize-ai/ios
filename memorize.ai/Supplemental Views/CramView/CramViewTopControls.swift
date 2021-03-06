import SwiftUI

struct CramViewTopControls<RecapView: View>: View {
	@Environment(\.presentationMode) var presentationMode
		
	let currentIndex: Int
	let numberOfTotalCards: Int
	let skipCard: () -> Void
	let recapView: () -> RecapView
	let onDisappear: () -> Void
	
	var title: String {
		"\(currentIndex + 1) / \(numberOfTotalCards)"
	}
	
	func button(text: String) -> some View {
		CustomRectangle(
			background: Color.clear,
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
				self.onDisappear()
				self.presentationMode.wrappedValue.dismiss()
			}) {
				XButton(.transparentWhite, height: 18)
			}
			Text(title)
				.font(.muli(.bold, size: 20))
				.foregroundColor(.white)
			Spacer()
			HStack {
				Button(action: skipCard) {
					button(text: "SKIP")
				}
				NavigationLink(
					destination: LazyView(content: recapView)
				) {
					button(text: "RECAP")
				}
			}
		}
	}
}

#if DEBUG
struct CramViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		CramViewTopControls(
			currentIndex: 1,
			numberOfTotalCards: 2,
			skipCard: {},
			recapView: { Text("Recap view") },
			onDisappear: {}
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

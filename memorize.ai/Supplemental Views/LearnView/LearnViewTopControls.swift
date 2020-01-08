import SwiftUI

struct LearnViewTopControls: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var model: LearnViewModel
	
	var title: String {
		"\(model.currentIndex + 1) / \(model.numberOfTotalCards)"
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
			HStack {
				Button(action: model.skipCard) {
					button(text: "SKIP")
				}
				LearnRecapViewNavigationLink {
					button(text: "DONE")
				}
			}
		}
	}
}

#if DEBUG
struct LearnViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		LearnViewTopControls()
			.environmentObject(LearnViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil
			))
	}
}
#endif

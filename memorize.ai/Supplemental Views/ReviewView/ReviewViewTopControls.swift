import SwiftUI

struct ReviewViewTopControls: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var model: ReviewViewModel
	
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
				ReviewRecapViewNavigationLink {
					button(text: "DONE")
				}
			}
		}
	}
}

#if DEBUG
struct ReviewViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewTopControls()
			.environmentObject(ReviewViewModel(
				user: PREVIEW_CURRENT_STORE.user,
				deck: nil,
				section: nil
			))
	}
}
#endif

import SwiftUI

struct ReviewViewPopUp: View {
	@EnvironmentObject var model: ReviewViewModel
	
	var body: some View {
		CustomRectangle(
			background: Color.lightGray.opacity(0.5),
			cornerRadius: 20
		) {
			VStack(spacing: 16) {
				if model.popUpData != nil {
					Text(model.popUpData?.emoji ?? "")
						.font(.muli(.regular, size: 50))
					Text(model.popUpData?.message ?? "")
						.font(.muli(.bold, size: 30))
						.foregroundColor(.darkGray)
				}
			}
			.padding(.vertical, 30)
			.frame(width: SCREEN_SIZE.width - 30 * 2)
		}
		.offset(x: model.popUpOffset)
	}
}

#if DEBUG
struct ReviewViewPopUp_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewPopUp()
			.environmentObject(ReviewViewModel(
				user: PREVIEW_CURRENT_STORE.user,
				deck: nil,
				section: nil
			))
	}
}
#endif

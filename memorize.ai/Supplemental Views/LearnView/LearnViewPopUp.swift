import SwiftUI

struct LearnViewPopUp: View {
	@EnvironmentObject var model: LearnViewModel
	
	var data: LearnViewModel.PopUpData? {
		model.popUpData
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.lightGray.opacity(0.5),
			cornerRadius: 20
		) {
			VStack(spacing: 16) {
				if data != nil {
					Text(data!.emoji)
						.font(.muli(.regular, size: 50))
					Text(data!.message)
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
struct LearnViewPopUp_Previews: PreviewProvider {
	static var previews: some View {
		let model = LearnViewModel(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			section: nil
		)
		model.popUpOffset = 0
		model.popUpData = ("🎉", "Great!")
		return LearnViewPopUp()
			.environmentObject(model)
	}
}
#endif

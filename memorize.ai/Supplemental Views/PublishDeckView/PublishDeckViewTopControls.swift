import SwiftUI

struct PublishDeckViewTopControls: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var model: PublishDeckViewModel
	
	var title: String {
		model.name.isEmpty
			? model.deck?.name ?? "Create deck"
			: model.name
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
			Button(action: model.publish) {
				CustomRectangle(
					background: Color.transparent,
					borderColor: .transparentLightGray,
					borderWidth: 1.5
				) {
					Text(model.deck == nil ? "Create" : "Edit")
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
struct PublishDeckViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		PublishDeckViewTopControls()
			.environmentObject(PublishDeckViewModel())
	}
}
#endif

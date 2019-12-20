import SwiftUI

struct AddCardsViewTopControls: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var model: AddCardsViewModel
	
	func goBack() {
		presentationMode.wrappedValue.dismiss()
	}
	
	var body: some View {
		HStack(spacing: 22) {
			Button(action: goBack) {
				XButton(.transparentWhite, height: 18)
			}
			Text("Add cards")
				.font(.muli(.bold, size: 20))
				.foregroundColor(.white)
			Spacer()
			Button(action: {
				self.model.publish(onDone: self.goBack)
			}) {
				CustomRectangle(
					background: Color.transparent,
					borderColor: .transparentLightGray,
					borderWidth: 1.5
				) {
					Group {
						if model.publishLoadingState.isLoading {
							ActivityIndicator()
								.padding(.horizontal, 25)
						} else {
							Text("PUBLISH")
								.font(.muli(.bold, size: 17))
								.foregroundColor(Color.white.opacity(0.7))
								.padding(.horizontal, 10)
						}
					}
					.frame(height: 30)
				}
				.opacity(model.isPublishButtonDisabled ? 0.5 : 1)
			}
			.disabled(model.isPublishButtonDisabled)
		}
	}
}

#if DEBUG
struct AddCardsViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		AddCardsViewTopControls()
			.environmentObject(AddCardsViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				user: PREVIEW_CURRENT_STORE.user
			))
	}
}
#endif

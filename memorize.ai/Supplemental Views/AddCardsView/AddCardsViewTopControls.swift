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
				CustomRectangle(background: Color.white) {
					Group {
						if model.publishLoadingState.isLoading {
							ActivityIndicator()
								.padding(.horizontal, 25)
						} else {
							Text("PUBLISH")
								.font(.muli(.bold, size: 17))
								.foregroundColor(.extraBluePurple)
								.padding(.horizontal, 10)
						}
					}
					.frame(height: 30)
				}
			}
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

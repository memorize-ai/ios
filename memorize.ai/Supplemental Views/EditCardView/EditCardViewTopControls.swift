import SwiftUI

struct EditCardViewTopControls: View {
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var card: Card.Draft
	
	func goBack() {
		presentationMode.wrappedValue.dismiss()
	}
	
	var body: some View {
		HStack(spacing: 22) {
			Button(action: goBack) {
				XButton(.transparentWhite, height: 18)
			}
			Text("Edit card")
				.font(.muli(.bold, size: 20))
				.foregroundColor(.white)
			Spacer()
			Button(action: {
				self.card.publishLoadingState.startLoading()
				self.card.publishAsUpdate().done {
					self.card.publishLoadingState.succeed()
				}.catch { error in
					self.card.publishLoadingState.fail(error: error)
				}
			}) {
				CustomRectangle(background: Color.white) {
					Group {
						if card.publishLoadingState.isLoading {
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
				.opacity(card.isPublishable ? 1 : 0.5)
			}
			.disabled(!card.isPublishable)
		}
	}
}

#if DEBUG
struct EditCardViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		EditCardViewTopControls(card: .init(
			parent: PREVIEW_CURRENT_STORE.user.decks.first!
		))
	}
}
#endif

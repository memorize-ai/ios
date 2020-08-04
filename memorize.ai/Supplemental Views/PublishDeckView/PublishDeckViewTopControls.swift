import SwiftUI

struct PublishDeckViewTopControls: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: PublishDeckViewModel
	
	var title: String {
		model.name.isEmpty
			? model.deck?.name ?? "Create deck"
			: model.name
	}
	
	func goBack() {
		presentationMode.wrappedValue.dismiss()
	}
	
	func onPublish(deckId: String) {
		if let deck = currentStore.user.deckWithId(deckId) {
			currentStore.goToDecksView(withDeck: deck)
		}
		goBack()
	}
	
	var body: some View {
		HStack(spacing: 0) {
			HStack(spacing: 22) {
				Button(action: goBack) {
					XButton(.transparentWhite, height: 18)
				}
				Text(title)
					.font(.muli(.bold, size: 20))
					.foregroundColor(.white)
			}
			.layoutPriority(1)
			Spacer()
			Button(action: {
				self.model.publish(
					currentUser: self.currentStore.user,
					completion: self.onPublish
				)
			}) {
				CustomRectangle(
					background: Color.clear,
					borderColor: .transparentLightGray,
					borderWidth: 1.5
				) {
					Group {
						if model.publishLoadingState.isLoading {
							ActivityIndicator()
								.padding(.horizontal, 25)
						} else {
							Text(model.deck == nil ? "Create" : "Publish")
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
struct PublishDeckViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		PublishDeckViewTopControls()
			.environmentObject(PublishDeckViewModel())
			.background(Color.black)
	}
}
#endif

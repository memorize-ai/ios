import SwiftUI

struct AddCardsViewTopControls<Destination: View>: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var model: AddCardsViewModel
	
	@State var shouldShowDestination = false
	
	let destination: Destination?
	
	func goToDestination() {
		destination == nil
			? presentationMode.wrappedValue.dismiss()
			: (shouldShowDestination = true)
	}
	
	var body: some View {
		Group {
			HStack(spacing: 22) {
				Button(action: goToDestination) {
					XButton(.transparentWhite, height: 18)
				}
				Text("Add cards")
					.font(.muli(.bold, size: 20))
					.foregroundColor(.white)
				Spacer()
				Button(action: {
					self.model.publish(onDone: self.goToDestination)
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
			destination.map {
				NavigateTo($0, when: $shouldShowDestination)
			}
		}
	}
}

#if DEBUG
struct AddCardsViewTopControls_Previews: PreviewProvider {
	static var previews: some View {
		AddCardsViewTopControls<EmptyView>(destination: nil)
			.environmentObject(AddCardsViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				user: PREVIEW_CURRENT_STORE.user
			))
	}
}
#endif

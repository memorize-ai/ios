import SwiftUI

struct AddCardsView: View {
	@EnvironmentObject var model: AddCardsViewModel
	
	var body: some View {
		Text("Hello, World!")
	}
}

#if DEBUG
struct AddCardsView_Previews: PreviewProvider {
	static var previews: some View {
		AddCardsView()
			.environmentObject(AddCardsViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!
			))
	}
}
#endif

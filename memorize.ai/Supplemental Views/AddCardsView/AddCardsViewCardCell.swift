import SwiftUI

struct AddCardsViewCardCell: View {
	@EnvironmentObject var model: AddCardsViewModel
	
	@ObservedObject var card: Card.Draft
	
	var section: some View {
		Text("Section")
	}
	
	var front: some View {
		Text("Front")
	}
	
	var back: some View {
		Text("Back")
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white
		) {
			VStack {
				section
				front
				back
			}
		}
	}
}

#if DEBUG
struct AddCardsViewCardCell_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.blue
				.edgesIgnoringSafeArea(.all)
			AddCardsViewCardCell(card: .init(
				parent: PREVIEW_CURRENT_STORE.user.decks.first!
			))
		}
		.environmentObject(AddCardsViewModel(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!
		))
	}
}
#endif

import SwiftUI

struct AddCardsViewCardCell: View {
	@EnvironmentOb
	@ObservedObject var card: Card
	
	var section
	
	var body: some View {
		CustomRectangle(
			background: Color.white
		) {
			VStack {
				
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
			AddCardsViewCardCell(
				card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0]
			)
		}
	}
}
#endif

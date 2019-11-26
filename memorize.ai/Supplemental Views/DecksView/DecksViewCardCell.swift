import SwiftUI

struct DecksViewCardCell: View {
	@ObservedObject var card: Card
	
	var body: some View {
		Text("DecksViewCardCell")
	}
}

#if DEBUG
struct DecksViewCardCell_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewCardCell(card: .init(
			id: "0",
			sectionId: "CSS",
			front: "This is the front of the card",
			back: "This is the back of the card",
			numberOfViews: 670,
			numberOfSkips: 40,
			userData: .init(dueDate: .init())
		))
	}
}
#endif

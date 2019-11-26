import SwiftUI

struct DecksViewCardCell: View {
	@ObservedObject var card: Card
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: Color.lightGrayBorder,
			borderWidth: 1,
			cornerRadius: 8,
			shadowRadius: 5,
			shadowYOffset: 5
		) {
			Text(card.front)
				.frame(maxWidth: .infinity, alignment: .leading)
				.frame(minHeight: 75, alignment: .top)
		}
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
		.padding(.horizontal, DecksView.horizontalPadding)
	}
}
#endif

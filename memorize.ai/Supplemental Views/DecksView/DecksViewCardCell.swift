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
			HStack(alignment: .top) {
				Text(Card.stripFormatting(card.front))
					.font(.muli(.semiBold, size: 15))
					.foregroundColor(.darkGray)
					.lineLimit(5)
					.align(to: .leading)
				if card.hasSound {
					Image(systemName: .speaker3Fill)
						.foregroundColor(.darkBlue)
						.padding([.trailing, .top], 3)
				}
			}
			.padding(8)
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
			front: "This is the front of the card<audio src=\"a\">ddasdflasjdfljlasdjfkljaldsjflkajlfdfjkjjjjjjjjjjjjjjjjjj<img src=\"https://www.desktopbackground.org/p/2010/11/29/118717_seashore-desktop-wallpapers-hd-images-jpg_2560x1600_h.jpg\">",
			back: "This is the back of the card",
			numberOfViews: 670,
			numberOfSkips: 40,
			userData: .init(dueDate: .init())
		))
		.padding(.horizontal, DecksView.horizontalPadding)
	}
}
#endif

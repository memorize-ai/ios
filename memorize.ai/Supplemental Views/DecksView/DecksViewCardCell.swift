import SwiftUI
import SwiftUIX

struct DecksViewCardCell: View {
	@ObservedObject var card: Card
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGrayBorder,
			borderWidth: 1,
			cornerRadius: 8,
			shadowRadius: 5,
			shadowYOffset: 5
		) {
			HStack(alignment: .top) {
				if !card.previewImageLoadingState.isNone {
					SwitchOver(card.previewImageLoadingState)
						.case(.loading) {
							ZStack {
								Color.lightGrayBackground
								ActivityIndicator(color: .gray)
							}
						}
						.case(.success) {
							card.previewImage?
								.resizable()
								.aspectRatio(contentMode: .fill)
						}
						.case(.failure) {
							ZStack {
								Color.lightGrayBackground
								Image(systemName: .exclamationmarkTriangle)
									.foregroundColor(.gray)
									.scaleEffect(1.5)
							}
						}
						.frame(width: 100, height: 100)
						.cornerRadius(5)
						.clipped()
				}
				Text(Card.stripFormatting(card.front).trimmed)
					.font(.muli(.semiBold, size: 15))
					.foregroundColor(.darkGray)
					.lineLimit(5)
					.lineSpacing(1)
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
		.onAppear {
			self.card.loadPreviewImage()
		}
	}
}

#if DEBUG
struct DecksViewCardCell_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewCardCell(card: .init(
			id: "0",
			sectionId: "CSS",
			front: #"This is the front of the card<audio src="a"></audio><h1>I am some big text</h1><img src="https://www.desktopbackground.org/p/2010/11/29/118717_seashore-desktop-wallpapers-hd-images-jpg_2560x1600_h.jpg">afadfasdfsasdsfasdfasdfasdfsdsfsasfsasdfasdfasdfasdfasdfasfsfsdfsdfsdfsdfsdfsdfsddsds"#,
			back: "This is the back of the card",
			numberOfViews: 670,
			numberOfSkips: 40,
			userData: .init(dueDate: .init())
		))
		.padding(.horizontal, DecksView.horizontalPadding)
	}
}
#endif

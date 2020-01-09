import SwiftUI
import SwiftUIX

struct DecksViewCardCell: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var card: Card
	
	var hasPreviewImage: Bool {
		!card.previewImageLoadingState.isNone
	}
	
	var body: some View {
		EditCardViewNavigationLink(
			deck: currentStore.selectedDeck!,
			card: card
		) {
			ZStack(alignment: .topLeading) {
				CustomRectangle(
					background: Color.white,
					borderColor: .lightGrayBorder,
					borderWidth: 1,
					cornerRadius: 8,
					shadowRadius: 5,
					shadowYOffset: 5
				) {
					VStack {
						HStack(alignment: .top) {
							if hasPreviewImage {
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
								.alignment(.leading)
						}
						.frame(minHeight: 40, alignment: .top)
						Text(card.dueMessage)
							.font(.muli(.bold, size: 12))
							.foregroundColor(Color.darkGray.opacity(0.7))
							.padding(.top, hasPreviewImage ? 0 : 4)
							.alignment(.leading)
					}
					.padding(8)
				}
				if card.isDue {
					Circle()
						.foregroundColor(Color.darkBlue.opacity(0.5))
						.frame(width: 12, height: 12)
						.offset(x: -4, y: -4)
				}
			}
			.onAppear {
				self.card.loadPreviewImage()
			}
		}
	}
}

#if DEBUG
struct DecksViewCardCell_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 20) {
			DecksViewCardCell(card: .init(
				id: "0",
				sectionId: "CSS",
				front: #"This is the front of the card<audio src="a"></audio><h1>I am some big text</h1><img src="https://www.desktopbackground.org/p/2010/11/29/118717_seashore-desktop-wallpapers-hd-images-jpg_2560x1600_h.jpg">afadfasdfsasdsfasdfasdfasdfdafafafafafasdsfsasfsasdfasdfasdfasdfasdfasfsfsdfsdfsdfsdfsdfsdfsddsds"#,
				back: "This is the back of the card",
				numberOfViews: 670,
				numberOfReviews: 0,
				numberOfSkips: 40,
				userData: .init(dueDate: Date().addingTimeInterval(10000))
			))
			.environmentObject(PREVIEW_CURRENT_STORE)
			DecksViewCardCell(card: .init(
				id: "0",
				sectionId: "CSS",
				front: #"This is some text"#,
				back: "This is the back of the card",
				numberOfViews: 670,
				numberOfReviews: 0,
				numberOfSkips: 40,
				userData: .init(dueDate: Date().addingTimeInterval(-10000))
			))
			.environmentObject(PREVIEW_CURRENT_STORE)
		}
		.padding(.horizontal, DecksView.horizontalPadding)
	}
}
#endif

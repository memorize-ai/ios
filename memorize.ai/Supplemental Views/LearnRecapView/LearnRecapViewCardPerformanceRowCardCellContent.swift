import SwiftUI
import SwiftUIX

struct LearnRecapViewCardPerformanceRowCardCellContent: View {
	@ObservedObject var card: Card
	
	var hasPreviewImage: Bool {
		!card.previewImageLoadingState.isNone
	}
	
	var body: some View {
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
		.onAppear {
			self.card.loadPreviewImage()
		}
	}
}

#if DEBUG
struct LearnRecapViewCardPerformanceRowCardCellContent_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewCardPerformanceRowCardCellContent(
			card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0]
		)
	}
}
#endif

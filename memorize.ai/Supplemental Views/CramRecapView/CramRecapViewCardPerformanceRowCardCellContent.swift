import SwiftUI

struct CramRecapViewCardPerformanceRowCardCellContent: View {
	@ObservedObject var card: Card
	@ObservedObject var section: Deck.Section
	
	let shouldShowSectionName: Bool
	
	var hasPreviewImage: Bool {
		!card.previewImageLoadingState.isNone
	}
	
	var body: some View {
		VStack {
			if shouldShowSectionName {
				Text(section.name)
					.font(.muli(.bold, size: 17))
					.foregroundColor(.lightGrayText)
					.layoutPriority(1)
					.alignment(.leading)
					.padding(.bottom, 8)
			}
			HStack(alignment: .top) {
				if hasPreviewImage {
					Group {
						if card.previewImageLoadingState == .loading {
							ZStack {
								Color.lightGrayBackground
								ActivityIndicator(color: .gray)
							}
						} else if card.previewImageLoadingState == .success {
							card.previewImage?
								.resizable()
								.aspectRatio(contentMode: .fill)
						} else if card.previewImageLoadingState == .failure {
							ZStack {
								Color.lightGrayBackground
								Image(systemName: .exclamationmarkTriangle)
									.foregroundColor(.gray)
									.scaleEffect(1.5)
							}
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
					.layoutPriority(1)
					.alignment(.leading)
			}
			.frame(minHeight: 40, alignment: .top)
		}
		.onAppear {
			self.card.loadPreviewImage()
		}
	}
}

#if DEBUG
struct CramRecapViewCardPerformanceRowCardCellContent_Previews: PreviewProvider {
	static var previews: some View {
		CramRecapViewCardPerformanceRowCardCellContent(
			card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0],
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0],
			shouldShowSectionName: true
		)
	}
}
#endif

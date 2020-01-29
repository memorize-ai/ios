import SwiftUI
import SwiftUIX

struct ReviewRecapViewCardPerformanceRowCardCell: View {
	@ObservedObject var deck: Deck
	@ObservedObject var section: Deck.Section
	@ObservedObject var card: Card
	@ObservedObject var reviewData: Card.ReviewData
	
	let shouldShowDeckName: Bool
	let shouldShowSectionName: Bool
	
	var hasPreviewImage: Bool {
		!card.previewImageLoadingState.isNone
	}
	
	var body: some View {
		ZStack(alignment: .topLeading) {
			CustomRectangle(
				background: Color.white,
				borderColor: reviewData.rating?.badgeColor ?? .white,
				borderWidth: 1,
				cornerRadius: 8
			) {
				VStack(alignment: .leading) {
					HStack {
						if shouldShowDeckName {
							Text(deck.name)
								.font(.muli(.bold, size: 17))
								.foregroundColor(.lightGrayText)
								.alignment(.leading)
								.padding(.bottom, 8)
							if shouldShowSectionName {
								Text("|")
							}
						}
						if shouldShowSectionName {
							Text(section.name)
								.font(.muli(.bold, size: 17))
								.foregroundColor(.lightGrayText)
								.alignment(.leading)
								.padding(.bottom, 8)
						}
						Spacer()
					}
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
				}
				.padding(8)
			}
			if reviewData.isNew {
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

#if DEBUG
struct ReviewRecapViewCardPerformanceRowCardCell_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewCardPerformanceRowCardCell(
			deck: PREVIEW_CURRENT_STORE.user.decks[0],
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0],
			card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0],
			reviewData: .init(
				parent: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0],
				userData: .init()
			),
			shouldShowDeckName: true,
			shouldShowSectionName: true
		)
	}
}
#endif

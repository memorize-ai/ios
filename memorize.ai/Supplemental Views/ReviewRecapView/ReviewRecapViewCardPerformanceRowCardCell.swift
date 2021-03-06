import SwiftUI

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
	
	var color: Color {
		reviewData.rating?.badgeColor ?? .white
	}
	
	var prediction: Date? {
		guard let rating = reviewData.rating else { return nil }
		return reviewData.predictionForRating(rating)
	}
	
	var predictionMessage: String {
		prediction.map { "Due \(Date().compare(against: $0))" } ?? "(error)"
	}
	
	var streakMessage: String {
		"\(reviewData.didIncreaseStreak ? "⚡️ " : "")\(reviewData.streak)x streak"
	}
	
	var body: some View {
		ZStack(alignment: .topLeading) {
			CustomRectangle(
				background: Color.white,
				borderColor: color,
				borderWidth: 1.5,
				cornerRadius: 8,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				VStack(alignment: .leading) {
					if card.isNew {
						Text("NEW")
							.font(.muli(.semiBold, size: 13))
							.foregroundColor(.darkBlue)
							.padding(
								.bottom,
								shouldShowDeckName || shouldShowSectionName ? -4 : 0
							)
					}
					HStack(alignment: .bottom) {
						if shouldShowDeckName {
							Text(deck.name)
								.font(.muli(.semiBold, size: 13))
								.foregroundColor(.darkGray)
								.shrinks()
								.layoutPriority(1)
							if shouldShowSectionName {
								Rectangle()
									.foregroundColor(.lightGrayBorder)
									.frame(width: 1.5, height: 14)
							}
						}
						if shouldShowSectionName {
							Text(section.name)
								.font(.muli(.semiBold, size: 13))
								.foregroundColor(.darkGray)
								.shrinks()
								.layoutPriority(1)
						}
						Spacer()
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
					HStack {
						CustomRectangle(background: color.opacity(0.1)) {
							Text(predictionMessage)
								.font(.muli(.bold, size: 13))
								.foregroundColor(.darkGray)
								.padding(.horizontal, 8)
								.padding(.vertical, 4)
						}
						Spacer()
						if reviewData.isNewlyMastered ?? false {
							HStack {
								Text("🎉")
								Text("Mastered!")
							}
							.font(.muli(.bold, size: 13))
							.foregroundColor(.darkGray)
						} else {
							Text(streakMessage)
								.font(.muli(.bold, size: 13))
								.foregroundColor(.darkGray)
						}
					}
					.padding(.top, 16)
					.padding(.trailing, 4)
				}
				.padding(8)
				.frame(maxWidth: .infinity)
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
			reviewData: {
				let reviewData = Card.ReviewData(
					parent: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0],
					userData: .init()
				)
				reviewData.rating = .easy
				reviewData.prediction = .init(functionResponse: [
					"0": .init(Date(timeIntervalSinceNow: 1000).timeIntervalSince1970 * 1000),
					"1": .init(Date(timeIntervalSinceNow: 1000).timeIntervalSince1970 * 1000),
					"2": .init(Date(timeIntervalSinceNow: 1000).timeIntervalSince1970 * 1000)
				])
				reviewData.isNewlyMastered = true
				return reviewData
			}(),
			shouldShowDeckName: true,
			shouldShowSectionName: true
		)
		.padding(.horizontal)
	}
}
#endif

import SwiftUI

struct MarketDeckViewRatings: View {
	@EnvironmentObject var deck: Deck
	
	func starRow(stars: Int, count: Int) -> some View {
		HStack {
			Text(String(stars))
				.font(.muli(.semiBold, size: 16))
				.foregroundColor(.lightGrayText)
			Image.grayStar
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 16, height: 16)
			GeometryReader { geometry in
				ZStack(alignment: .leading) {
					Capsule()
						.opacity(0.3)
					Capsule()
						.frame(
							width: geometry.size.width *
								.init(count) / .init(self.deck.numberOfRatings)
						)
				}
				.foregroundColor(.darkBlue)
			}
			.frame(maxWidth: 122)
			.frame(height: 4)
			Text(count.formatted)
				.font(.muli(.semiBold, size: 16))
				.foregroundColor(.darkGray)
				.frame(minWidth: 45, alignment: .leading)
		}
	}
	
	var body: some View {
		VStack {
			MarketDeckViewSectionTitle("Ratings")
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGray,
				borderWidth: 1.5,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				VStack {
					HStack {
						VStack {
							DeckStars(stars: deck.averageRating)
								.scaleEffect(1.2)
						}
						Spacer()
						VStack(spacing: 4) {
							starRow(stars: 5, count: deck.numberOf5StarRatings)
							starRow(stars: 4, count: deck.numberOf4StarRatings)
							starRow(stars: 3, count: deck.numberOf3StarRatings)
							starRow(stars: 2, count: deck.numberOf2StarRatings)
							starRow(stars: 1, count: deck.numberOf1StarRatings)
						}
					}
				}
			}
		}
		.padding(.horizontal, 23)
	}
}

#if DEBUG
struct MarketDeckViewRatings_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewRatings()
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

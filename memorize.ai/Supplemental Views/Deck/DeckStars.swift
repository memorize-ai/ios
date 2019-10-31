import SwiftUI

struct DeckStars: View {
	let stars: Double
	
	var body: some View {
		HStack(spacing: 1) {
			DeckStar(
				fill: .init(min(1, stars)),
				dimension: 15
			)
			DeckStar(
				fill: .init(min(1, max(0, stars - 1))),
				dimension: 15
			)
			DeckStar(
				fill: .init(min(1, max(0, stars - 2))),
				dimension: 15
			)
			DeckStar(
				fill: .init(min(1, max(0, stars - 3))),
				dimension: 15
			)
			DeckStar(
				fill: .init(min(1, max(0, stars - 4))),
				dimension: 15
			)
		}
	}
}

#if DEBUG
struct DeckStars_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 20) {
			DeckStars(stars: 3.4)
			DeckStars(stars: 4.5)
			DeckStars(stars: 5)
			DeckStars(stars: 1.2)
			DeckStars(stars: 0.5)
		}
	}
}
#endif

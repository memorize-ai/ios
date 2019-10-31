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
				fill: .init(min(1, stars - 1)),
				dimension: 15
			)
			DeckStar(
				fill: .init(min(1, stars - 2)),
				dimension: 15
			)
			DeckStar(
				fill: .init(min(1, stars - 3)),
				dimension: 15
			)
			DeckStar(
				fill: .init(min(1, stars - 4)),
				dimension: 15
			)
		}
	}
}

#if DEBUG
struct DeckStars_Previews: PreviewProvider {
	static var previews: some View {
		DeckStars(stars: 4.5)
	}
}
#endif

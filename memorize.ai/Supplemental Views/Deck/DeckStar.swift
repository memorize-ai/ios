import SwiftUI

struct DeckStar: View {
	let fill: CGFloat
	let dimension: CGFloat
	
	var relativeFill: CGFloat {
		dimension * fill
	}
	
	var body: some View {
		ZStack {
			HStack(spacing: 0) {
				Color.neonGreen
					.frame(width: relativeFill)
				Color.white
					.frame(width: dimension - relativeFill)
			}
			.frame(height: dimension - 1)
			Image.deckStar
				.resizable()
				.renderingMode(.original)
				.aspectRatio(contentMode: .fit)
				.frame(width: dimension, height: dimension)
		}
	}
}

#if DEBUG
struct DeckStar_Previews: PreviewProvider {
	static var previews: some View {
		DeckStar(fill: 0.5, dimension: 15)
	}
}
#endif

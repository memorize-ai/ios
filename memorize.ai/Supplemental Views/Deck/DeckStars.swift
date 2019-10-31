import SwiftUI

struct DeckStars: View {
	let stars: Double
	
	var body: some View {
		Text(String(stars))
	}
}

#if DEBUG
struct DeckStars_Previews: PreviewProvider {
	static var previews: some View {
		DeckStars(stars: 4.5)
	}
}
#endif

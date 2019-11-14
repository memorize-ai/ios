import SwiftUI

struct HomeViewRecommendedDecksSection: View {
	var body: some View {
		Text("Recommended Decks")
			.font(.muli(.bold, size: 17))
			.foregroundColor(.darkGray)
	}
}

#if DEBUG
struct HomeViewRecommendedDecksSection_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewRecommendedDecksSection()
	}
}
#endif

import SwiftUI

struct MarketDeckViewSectionTitle: View {
	let title: String
	
	init(_ title: String) {
		self.title = title
	}
	
	var body: some View {
		Text(title)
			.font(.muli(.bold, size: 20))
			.foregroundColor(.darkGray)
			.align(to: .leading)
	}
}

#if DEBUG
struct MarketDeckViewSectionTitle_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewSectionTitle("Ratings")
	}
}
#endif

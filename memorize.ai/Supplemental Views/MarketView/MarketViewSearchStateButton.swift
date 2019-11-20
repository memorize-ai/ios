import SwiftUI

struct MarketViewSearchStateButton: View {
	let icon: Image
	let title: String
	let onClick: () -> Void
	
	var body: some View {
		Text("MarketViewSearchStateButton")
	}
}

#if DEBUG
struct MarketViewSearchStateButton_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			MarketViewSearchStateButton(
				icon: .sortIcon,
				title: "SORT"
			) {}
			MarketViewSearchStateButton(
				icon: .filterIcon,
				title: "FILTER"
			) {}
		}
	}
}
#endif

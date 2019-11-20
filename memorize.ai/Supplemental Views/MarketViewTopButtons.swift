import SwiftUI

struct MarketViewTopButtons: View {
	var body: some View {
		HStack(spacing: 13) {
			MarketViewSearchStateButton(
				icon: .sortIcon,
				title: "SORT"
			) {
				// TODO: Show sort pop-up view
			}
			MarketViewSearchStateButton(
				icon: .filterIcon,
				title: "FILTER"
			) {
				// TODO: Show filter sheet view
			}
		}
	}
}

#if DEBUG
struct MarketViewTopButtons_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewTopButtons()
	}
}
#endif

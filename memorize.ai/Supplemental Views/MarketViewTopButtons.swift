import SwiftUI

struct MarketViewTopButtons: View {
	var body: some View {
		HStack(spacing: 13) {
			MarketViewSearchStateButton()
			MarketViewSearchStateButton()
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

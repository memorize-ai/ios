import SwiftUI

struct MarketViewTopButtons: View {
	@ObservedObject var model: MarketViewModel
	
	var body: some View {
		HStack(spacing: 13) {
			MarketViewSearchStateButton(
				icon: .sortIcon,
				title: "SORT"
			) {
				popUpWithAnimation {
					self.model.isSortPopUpShowing = true
				}
			}
			MarketViewSearchStateButton(
				icon: .filterIcon,
				title: "FILTER"
			) {
				popUpWithAnimation {
					self.model.isFilterPopUpShowing = true
				}
			}
		}
	}
}

#if DEBUG
struct MarketViewTopButtons_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewTopButtons(model: .init())
	}
}
#endif

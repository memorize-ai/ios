import SwiftUI

struct MarketViewTopButtons: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@Binding var isSortPopUpShowing: Bool
	@Binding var isFilterPopUpShowing: Bool
	
	var body: some View {
		HStack(spacing: 13) {
			MarketViewSearchStateButton(
				icon: .sortIcon,
				title: "SORT"
			) {
				popUpWithAnimation {
					self.isSortPopUpShowing = true
				}
			}
			MarketViewSearchStateButton(
				icon: .filterIcon,
				title: "FILTER"
			) {
				popUpWithAnimation {
					self.isFilterPopUpShowing = true
				}
			}
		}
	}
}

#if DEBUG
struct MarketViewTopButtons_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewTopButtons(
			isSortPopUpShowing: .constant(false),
			isFilterPopUpShowing: .constant(false)
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

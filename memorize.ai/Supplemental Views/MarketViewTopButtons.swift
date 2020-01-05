import SwiftUI

struct MarketViewTopButtons: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: MarketViewModel
	
	func loadTopicsIfNeeded() {
		guard model.filterPopUpSideBarSelection == .topics else { return }
		for topic in currentStore.topics {
			topic.loadImage()
		}
	}
	
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
				self.loadTopicsIfNeeded()
			}
		}
	}
}

#if DEBUG
struct MarketViewTopButtons_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewTopButtons()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(MarketViewModel(currentUser: PREVIEW_CURRENT_STORE.user))
	}
}
#endif

import SwiftUI
import SwiftUIX

struct MarketViewFilterPopUp: View {
	static let contentFullHeightRatio: CGFloat = 424 / 667
	static let contentHeight = SCREEN_SIZE.height * contentFullHeightRatio
	
	@EnvironmentObject var model: MarketViewModel
	
	var body: some View {
		PopUp(
			isShowing: $model.isFilterPopUpShowing,
			contentHeight: Self.contentHeight
		) {
			HStack(spacing: 0) {
				MarketViewFilterPopUpSideBar()
				SwitchOver(model.filterPopUpSideBarSelection)
					.case(.topics) {
						Text("Topics") // TODO: Show topics list
					}
					.case(.rating) {
						Text("Rating") // TODO: Show rating slider
					}
					.case(.downloads) {
						Text("Downloads") // TODO: Show downloads slider
					}
			}
		}
	}
}

#if DEBUG
struct MarketViewFilterPopUp_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewFilterPopUp()
			.environmentObject(MarketViewModel())
	}
}
#endif

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
				Spacer()
				SwitchOver(model.filterPopUpSideBarSelection)
					.case(.topics) {
						MarketViewFilterPopUpTopicsContent()
					}
					.case(.rating) {
						Text("Rating") // TODO: Show rating slider
					}
					.case(.downloads) {
						Text("Downloads") // TODO: Show downloads slider
					}
					.frame(height: Self.contentHeight)
				Spacer()
			}
		}
	}
}

#if DEBUG
struct MarketViewFilterPopUp_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewFilterPopUp()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(MarketViewModel())
	}
}
#endif

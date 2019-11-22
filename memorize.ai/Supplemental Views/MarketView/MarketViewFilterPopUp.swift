import SwiftUI
import SwiftUIX

struct MarketViewFilterPopUp: View {
	static let contentFullHeightRatio: CGFloat = 424 / 667
	static let contentHeight = SCREEN_SIZE.height * contentFullHeightRatio
	
	@EnvironmentObject var model: MarketViewModel
	
	var body: some View {
		PopUp(
			isShowing: $model.isFilterPopUpShowing,
			contentHeight: Self.contentHeight,
			onHide: model.loadSearchResults
		) {
			HStack(spacing: 0) {
				MarketViewFilterPopUpSideBar()
				Spacer()
				SwitchOver(model.filterPopUpSideBarSelection)
					.case(.topics) {
						MarketViewFilterPopUpTopicsContent()
					}
					.case(.rating) {
						MarketViewFilterPopUpContentWithSlider(
							value: $model.ratingFilter,
							leadingText: "Must have over",
							trailingText:
								"star\(model.ratingFilter == 1 ? "" : "s")",
							lowerBound: 0,
							upperBound: 5
						)
					}
					.case(.downloads) {
						MarketViewFilterPopUpContentWithSlider(
							value: $model.downloadsFilter,
							leadingText: "Must have over",
							trailingText:
								"download\(model.downloadsFilter == 1 ? "" : "s")",
							lowerBound: 0,
							upperBound: 10 * 1000
						)
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

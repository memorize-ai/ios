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
			onHide: {
				self.model.loadSearchResults(force: true)
			}
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
							upperBound: 5,
							formatAsInt: false
						)
					}
					.case(.downloads) {
						MarketViewFilterPopUpContentWithSlider(
							value: $model.downloadsFilter,
							leadingText: "Must have over",
							trailingText:
								"download\(model.downloadsFilter == 1 ? "" : "s")",
							lowerBound: 0,
							upperBound: 10e3,
							formatAsInt: true
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
			.environmentObject(MarketViewModel(
				currentUser: PREVIEW_CURRENT_STORE.user
			))
	}
}
#endif

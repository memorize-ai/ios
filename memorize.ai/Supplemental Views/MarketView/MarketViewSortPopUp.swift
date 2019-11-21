import SwiftUI

struct MarketViewSortPopUp: View {
	@EnvironmentObject var model: MarketViewModel
	
	var body: some View {
		PopUp(
			isShowing: $model.isSortPopUpShowing,
			contentHeight: 50 * 3 + 2
		) {
			EmptyView() // TODO: Sort pop up view content
		}
	}
}

#if DEBUG
struct MarketViewSortPopUp_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewSortPopUp()
			.environmentObject(MarketViewModel())
	}
}
#endif

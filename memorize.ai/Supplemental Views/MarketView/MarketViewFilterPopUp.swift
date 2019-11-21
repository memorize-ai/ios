import SwiftUI

struct MarketViewFilterPopUp: View {
	@EnvironmentObject var model: MarketViewModel
	
	var body: some View {
		PopUp(
			isShowing: $model.isFilterPopUpShowing,
			contentHeight: 0 // TODO: Filter pop up view content height
		) {
			EmptyView() // TODO: Filter pop up view content
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

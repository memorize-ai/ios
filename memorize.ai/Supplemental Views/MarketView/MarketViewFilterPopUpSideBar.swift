import SwiftUI

struct MarketViewFilterPopUpSideBar: View {
	@EnvironmentObject var model: MarketViewModel
	
	var body: some View {
		Text("MarketViewFilterPopUpSideBar")
	}
}

#if DEBUG
struct MarketViewFilterPopUpSideBar_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewFilterPopUpSideBar()
			.environmentObject(MarketViewModel())
	}
}
#endif

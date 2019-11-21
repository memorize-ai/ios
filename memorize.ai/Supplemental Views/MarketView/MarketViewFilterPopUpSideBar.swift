import SwiftUI

struct MarketViewFilterPopUpSideBar: View {
	@EnvironmentObject var model: MarketViewModel
	
	var body: some View {
		HStack(spacing: 0) {
			VStack {
				// TODO: Add elements
				Spacer()
			}
			.frame(width: 50)
			.background(Color.lightGrayBackground)
			Rectangle()
				.foregroundColor(literal: #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1))
				.frame(width: 1)
		}
		.frame(height: MarketViewFilterPopUp.contentHeight)
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

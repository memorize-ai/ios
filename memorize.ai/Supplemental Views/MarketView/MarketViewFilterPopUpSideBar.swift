import SwiftUI

struct MarketViewFilterPopUpSideBar: View {
	@EnvironmentObject var model: MarketViewModel
	
	var topicsButton: some View {
		MarketViewFilterPopUpSideBarButton(
			selectedIcon: {
				
			},
			unselectedIcon: {
				
			},
			isSelected: model.filterPopUpSideBarSelection == .topics
		) {
			self.model.filterPopUpSideBarSelection = .topics
		}
	}
	
	var ratingButton: some View {
		MarketViewFilterPopUpSideBarButton(
			selectedIcon: {
				
			},
			unselectedIcon: {
				
			},
			isSelected: model.filterPopUpSideBarSelection == .rating
		) {
			self.model.filterPopUpSideBarSelection = .rating
		}
	}
	
	var downloadsButton: some View {
		MarketViewFilterPopUpSideBarButton(
			selectedIcon: {
				
			},
			unselectedIcon: {
				
			},
			isSelected: model.filterPopUpSideBarSelection == .downloads
		) {
			self.model.filterPopUpSideBarSelection = .downloads
		}
	}
	
	var body: some View {
		HStack(spacing: 0) {
			VStack {
				topicsButton
				ratingButton
				downloadsButton
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

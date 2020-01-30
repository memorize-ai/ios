import SwiftUI

struct MarketViewSortPopUp: View {
	@EnvironmentObject var model: MarketViewModel
	
	var check: some View {
		Image(systemName: .checkmark)
			.foregroundColor(.darkBlue)
	}
	
	func button(forAlgorithm algorithm: Deck.SortAlgorithm) -> some View {
		let isSelected = model.sortAlgorithm == algorithm
		
		return PopUpButton(
			icon: isSelected ? check : nil,
			text: algorithm.rawValue,
			textColor: isSelected ? .darkBlue : .lightGrayText
		) {
			self.model.sortAlgorithm = algorithm
		}
	}
	
	var body: some View {
		PopUp(
			isShowing: $model.isSortPopUpShowing,
			contentHeight: 50 * 7 + 6,
			onHide: model.loadSearchResults
		) {
			Group {
				button(forAlgorithm: .recommended)
				PopUpDivider()
				button(forAlgorithm: .relevance)
				PopUpDivider()
				button(forAlgorithm: .top)
				PopUpDivider()
				button(forAlgorithm: .rating)
				PopUpDivider()
				button(forAlgorithm: .currentUsers)
				PopUpDivider()
			}
			Group {
				button(forAlgorithm: .new)
				PopUpDivider()
				button(forAlgorithm: .recentlyUpdated)
			}
		}
	}
}

#if DEBUG
struct MarketViewSortPopUp_Previews: PreviewProvider {
	static var previews: some View {
		MarketViewSortPopUp()
			.environmentObject(MarketViewModel(
				currentUser: PREVIEW_CURRENT_STORE.user
			))
	}
}
#endif

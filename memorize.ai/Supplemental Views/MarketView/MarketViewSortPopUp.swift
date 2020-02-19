import SwiftUI

struct MarketViewSortPopUp: View {
	@Binding var isSortPopUpShowing: Bool
	@Binding var sortAlgorithm: Deck.SortAlgorithm
	
	let loadSearchResults: (Bool) -> Void
	
	var check: some View {
		Image(systemName: .checkmark)
			.foregroundColor(.darkBlue)
	}
	
	func button(forAlgorithm algorithm: Deck.SortAlgorithm) -> some View {
		let isSelected = sortAlgorithm == algorithm
		
		return PopUpButton(
			icon: isSelected ? check : nil,
			text: algorithm.rawValue,
			textColor: isSelected ? .darkBlue : .lightGrayText
		) {
			self.sortAlgorithm = algorithm
		}
	}
	
	var body: some View {
		PopUp(
			isShowing: $isSortPopUpShowing,
			contentHeight: 50 * 7 + 6,
			onHide: {
				self.loadSearchResults(true)
			}
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
		MarketViewSortPopUp(
			isSortPopUpShowing: .constant(true),
			sortAlgorithm: .constant(.recommended),
			loadSearchResults: { _ in }
		)
	}
}
#endif

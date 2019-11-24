import SwiftUI

struct MarketViewSortPopUp: View {
	@EnvironmentObject var model: MarketViewModel
	
	var check: some View {
		Image(systemName: .checkmark)
			.foregroundColor(.darkBlue)
	}
	
	var body: some View {
		PopUp(
			isShowing: $model.isSortPopUpShowing,
			contentHeight: 50 * 5 + 4,
			onHide: model.loadSearchResults
		) {
			PopUpButton(
				icon: model.sortAlgorithm == .recommended ? check : nil,
				text: "Recommended",
				textColor: model.sortAlgorithm == .recommended
					? .darkBlue
					: .lightGrayText
			) {
				self.model.sortAlgorithm = .recommended
			}
			PopUpDivider()
			PopUpButton(
				icon: model.sortAlgorithm == .relevance ? check : nil,
				text: "Relevance",
				textColor: model.sortAlgorithm == .relevance
					? .darkBlue
					: .lightGrayText
			) {
				self.model.sortAlgorithm = .relevance
			}
			PopUpDivider()
			PopUpButton(
				icon: model.sortAlgorithm == .top ? check : nil,
				text: "Top",
				textColor: model.sortAlgorithm == .top
					? .darkBlue
					: .lightGrayText
			) {
				self.model.sortAlgorithm = .top
			}
			PopUpDivider()
			PopUpButton(
				icon: model.sortAlgorithm == .new ? check : nil,
				text: "New",
				textColor: model.sortAlgorithm == .new
					? .darkBlue
					: .lightGrayText
			) {
				self.model.sortAlgorithm = .new
			}
			PopUpDivider()
			PopUpButton(
				icon: model.sortAlgorithm == .recentlyUpdated ? check : nil,
				text: "Recently updated",
				textColor: model.sortAlgorithm == .recentlyUpdated
					? .darkBlue
					: .lightGrayText
			) {
				self.model.sortAlgorithm = .recentlyUpdated
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

import SwiftUI

struct MarketViewFilterPopUp: View {
	static let contentFullHeightRatio: CGFloat = 424 / 667
	static let contentHeight = SCREEN_SIZE.height * contentFullHeightRatio
	
	@Binding var isFilterPopUpShowing: Bool
	@Binding var topicsFilter: [Topic]?
	@Binding var ratingFilter: Double
	@Binding var downloadsFilter: Double
	@Binding var filterPopUpSideBarSelection: MarketView.FilterPopUpSideBarSelection
	
	let loadSearchResults: (Bool) -> Void
	let isTopicSelected: (Topic) -> Bool
	let toggleTopicSelect: (Topic) -> Void
	
	let geometry: GeometryProxy
	
	var body: some View {
		PopUp(
			isShowing: $isFilterPopUpShowing,
			contentHeight: Self.contentHeight,
			onHide: {
				self.loadSearchResults(true)
			},
			geometry: geometry
		) {
			HStack(spacing: 0) {
				MarketViewFilterPopUpSideBar(
					filterPopUpSideBarSelection: $filterPopUpSideBarSelection
				)
				Spacer()
				Group {
					switch filterPopUpSideBarSelection {
					case .topics:
						if isFilterPopUpShowing {
							MarketViewFilterPopUpTopicsContent(
								topicsFilter: $topicsFilter,
								isTopicSelected: isTopicSelected,
								toggleTopicSelect: toggleTopicSelect
							)
						}
					case .rating:
						MarketViewFilterPopUpContentWithSlider(
							value: $ratingFilter,
							leadingText: "Must have over",
							trailingText:
								"star\(ratingFilter == 1 ? "" : "s")",
							lowerBound: 0,
							upperBound: 5,
							formatAsInt: false
						)
					case .downloads:
						MarketViewFilterPopUpContentWithSlider(
							value: $downloadsFilter,
							leadingText: "Must have over",
							trailingText:
								"download\(downloadsFilter == 1 ? "" : "s")",
							lowerBound: 0,
							upperBound: 10e3,
							formatAsInt: true
						)
					}
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
		GeometryReader { geometry in
			MarketViewFilterPopUp(
				isFilterPopUpShowing: .constant(true),
				topicsFilter: .constant(nil),
				ratingFilter: .constant(20),
				downloadsFilter: .constant(20),
				filterPopUpSideBarSelection: .constant(.topics),
				loadSearchResults: { _ in },
				isTopicSelected: { _ in true },
				toggleTopicSelect: { _ in },
				geometry: geometry
			)
			.environmentObject(PREVIEW_CURRENT_STORE)
		}
	}
}
#endif

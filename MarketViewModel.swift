import Combine

final class MarketViewModel: ObservableObject {
	enum FilterPopUpSideBarSelection {
		case topics
		case rating
		case downloads
	}
	
	enum SortAlgorithm {
		case relevance
		case top
		case recentlyUpdated
	}
	
	@Published var searchText = "" {
		didSet {
			loadSearchResults()
		}
	}
	
	@Published var isSortPopUpShowing = false
	@Published var isFilterPopUpShowing = false
	
	@Published var filterPopUpSideBarSelection = FilterPopUpSideBarSelection.topics
	
	@Published var sortAlgorithm = SortAlgorithm.relevance
	
	@Published var topicsFilter: [Topic]?
	@Published var ratingFilter: Double?
	@Published var downloadsFilter: Int?
	
	@Published var searchResults = [Deck]()
	
	func loadSearchResults() {
		// TODO: Load search results
		print("LOAD_SEARCH_RESULTS:")
		print("\tsortAlgorithm = \(sortAlgorithm)")
		print("\ttopicsFilter = \(String(describing: topicsFilter))")
		print("\tratingFilter = \(String(describing: ratingFilter))")
		print("\tdownloadsFilter = \(String(describing: downloadsFilter))")
	}
}

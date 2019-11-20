import Combine

final class MarketViewModel: ObservableObject {
	enum SortAlgorithm {
		case relevance
		case top
		case recentlyUpdated
	}
	
	enum Filter {
		case topics([Topic])
		case rating(greaterThan: Double)
		case downloads(greaterThan: Int)
	}
	
	@Published var searchText = "" {
		didSet {
			loadSearchResults()
		}
	}
	
	@Published var sortAlgorithm = SortAlgorithm.relevance
	@Published var filters = [Filter]()
	
	@Published var searchResults = [Deck]()
	
	func loadSearchResults() {
		// TODO: Load search results
	}
}

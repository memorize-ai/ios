import Combine

final class MarketViewModel: ObservableObject {
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
	
	@Published var sortAlgorithm = SortAlgorithm.relevance
	
	@Published var topicsFilter: [Topic]?
	@Published var ratingFilter: Double?
	@Published var downloadsFilter: Int?
	
	@Published var searchResults = [Deck]()
	
	func loadSearchResults() {
		// TODO: Load search results
	}
}

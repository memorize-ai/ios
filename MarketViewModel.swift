import Combine
import LoadingState

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
	@Published var ratingFilter = 0.0
	@Published var downloadsFilter = 0.0
	
	@Published var searchResults = [Deck]()
	@Published var searchResultsLoadingState = LoadingState()
	
	func loadSearchResults() {
		searchResultsLoadingState.startLoading()
		Deck.search(
			query: searchText,
			filterForTopics: topicsFilter,
			averageRatingGreaterThan: ratingFilter.isZero
				? nil
				: ratingFilter,
			numberOfDownloadsGreaterThan: downloadsFilter.isZero
				? nil
				: .init(downloadsFilter)
		).done { decks in
			self.searchResults = decks.map { $0.loadImage() }
			self.searchResultsLoadingState.succeed()
		}.catch { error in
			self.searchResultsLoadingState.fail(error: error)
		}
		
		// TODO: Remove these
		print("LOAD_SEARCH_RESULTS:")
		print("\tsearchText = \"\(searchText)\"")
		print("\tsortAlgorithm = \(sortAlgorithm)")
		print("\ttopicsFilter = \(String(describing: topicsFilter))")
		print("\tratingFilter = \(ratingFilter)")
		print("\tdownloadsFilter = \(downloadsFilter)")
	}
	
	func isTopicSelected(_ topic: Topic) -> Bool {
		topicsFilter?.contains(topic) ?? true
	}
	
	func toggleTopicSelect(_ topic: Topic) {
		isTopicSelected(topic)
			? topicsFilter?.removeAll { $0 == topic }
			: topicsFilter?.append(topic)
	}
}

import Combine
import LoadingState

final class MarketViewModel: ObservableObject {
	let currentUser: User
	
	init(currentUser: User) {
		self.currentUser = currentUser
	}
	
	enum FilterPopUpSideBarSelection {
		case topics
		case rating
		case downloads
	}
	
	@Published var searchText = "" {
		didSet {
			loadSearchResults()
		}
	}
	
	@Published var isSortPopUpShowing = false
	@Published var isFilterPopUpShowing = false
	
	@Published var filterPopUpSideBarSelection = FilterPopUpSideBarSelection.topics
	
	@Published var sortAlgorithm = Deck.SortAlgorithm.recommended
	
	@Published var topicsFilter: [Topic]?
	@Published var ratingFilter = 0.0
	@Published var downloadsFilter = 0.0
	
	@Published var searchResults = [Deck]()
	@Published var searchResultsLoadingState = LoadingState()
	
	var deckSearchRatingFilter: Double? {
		sortAlgorithm == .recommended || ratingFilter.isZero
			? nil
			: ratingFilter
	}
	
	var deckSearchDownloadsFilter: Int? {
		sortAlgorithm == .recommended || downloadsFilter.isZero
			? nil
			: .init(downloadsFilter)
	}
	
	func loadSearchResults() {
		searchResultsLoadingState.startLoading()
		Deck.search(
			query: sortAlgorithm == .recommended ? "" : searchText,
			filterForTopics: sortAlgorithm == .recommended
				? currentUser.interests
				: topicsFilter?.map(~\.id),
			averageRatingGreaterThan: deckSearchRatingFilter,
			numberOfDownloadsGreaterThan: deckSearchDownloadsFilter,
			sortBy: sortAlgorithm
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

import Combine
import PromiseKit
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
		ratingFilter.isZero
			? nil
			: ratingFilter
	}
	
	var deckSearchDownloadsFilter: Int? {
		downloadsFilter.isZero
			? nil
			: .init(downloadsFilter)
	}
	
	var searchResultsPromise: Promise<[Deck]> {
		sortAlgorithm == .recommended
			? currentUser.recommendedDecks()
			: Deck.search(
				query: searchText,
				filterForTopics: topicsFilter?.map(~\.id),
				averageRatingGreaterThan: deckSearchRatingFilter,
				numberOfDownloadsGreaterThan: deckSearchDownloadsFilter,
				sortBy: sortAlgorithm
			)
	}
	
	func loadSearchResults() {
		searchResultsLoadingState.startLoading()
		searchResultsPromise.done { decks in
			self.searchResults = decks.map { $0.loadImage() }
			self.searchResultsLoadingState.succeed()
		}.catch { error in
			self.searchResultsLoadingState.fail(error: error)
		}
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

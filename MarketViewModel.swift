import Combine
import PromiseKit
import LoadingState

final class MarketViewModel: ViewModel {
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
			switchSortAlgorithmIfNeeded()
			loadSearchResults(force: true)
		}
	}
	
	@Published var isSortPopUpShowing = false
	@Published var isFilterPopUpShowing = false
	
	@Published var filterPopUpSideBarSelection = FilterPopUpSideBarSelection.topics
	
	@Published var sortAlgorithm = Deck.SortAlgorithm.recommended
	
	@Published var topicsFilter: [Topic]? {
		didSet {
			switchSortAlgorithmIfNeeded()
		}
	}
	
	@Published var ratingFilter = 0.0 {
		didSet {
			switchSortAlgorithmIfNeeded()
		}
	}
	
	@Published var downloadsFilter = 0.0 {
		didSet {
			switchSortAlgorithmIfNeeded()
		}
	}
	
	@Published var searchResults = [Deck]()
	@Published var searchResultsLoadingState = LoadingState()
	
	func switchSortAlgorithmIfNeeded() {
		if searchText.isEmpty && topicsFilter == nil && ratingFilter.isZero && downloadsFilter.isZero {
			sortAlgorithm = .recommended
		} else if sortAlgorithm == .recommended {
			sortAlgorithm = .relevance
		}
	}
	
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
	
	func loadSearchResults(force: Bool = false) {
		guard force || searchResultsLoadingState.isNone else { return }
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

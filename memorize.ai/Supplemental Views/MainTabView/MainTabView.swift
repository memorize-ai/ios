import SwiftUI
import SwiftUIX
import PromiseKit
import LoadingState

struct MainTabView: View {
	enum Selection {
		case home
		case market
		case decks
		case profile
	}
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var currentUser: User
	
	@ObservedObject var decksViewModel = DecksViewModel()
	
	func setSelection(to selection: Selection) {
		currentStore.mainTabViewSelection = selection
	}
	
	var currentSelection: Selection {
		currentStore.mainTabViewSelection
	}
	
	// MARK: - Market View [START]
	
	@State var searchText = "" {
		didSet {
			switchSortAlgorithmIfNeeded()
			loadSearchResults(force: true)
		}
	}
	
	@State var isSortPopUpShowing = false
	@State var isFilterPopUpShowing = false

	@State var filterPopUpSideBarSelection = MarketView.FilterPopUpSideBarSelection.topics

	@State var sortAlgorithm = Deck.SortAlgorithm.recommended

	@State var topicsFilter: [Topic]? = nil {
		didSet {
			switchSortAlgorithmIfNeeded()
		}
	}
	
	@State var ratingFilter = 0.0 {
		didSet {
			switchSortAlgorithmIfNeeded()
		}
	}
	
	@State var downloadsFilter = 0.0 {
		didSet {
			switchSortAlgorithmIfNeeded()
		}
	}
	
	@State var searchResults = [Deck]()
	@State var searchResultsLoadingState = LoadingState()
	
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
			? currentStore.user.recommendedDecks()
			: Deck.search(
				query: searchText,
				filterForTopics: topicsFilter?.map(~\.id),
				averageRatingGreaterThan: deckSearchRatingFilter,
				numberOfDownloadsGreaterThan: deckSearchDownloadsFilter,
				sortBy: sortAlgorithm
			)
	}
	
	func loadSearchResults(force: Bool) {
		guard force || searchResultsLoadingState.isNone else { return }
		searchResultsLoadingState.startLoading()
		self.searchResultsPromise.done { decks in
			self.searchResults = decks.map { $0.loadImage() }
			self.searchResultsLoadingState.succeed()
		}.catch { error in
			self.searchResultsLoadingState.fail(error: error)
			showAlert(title: "An error occurred", message: error.localizedDescription)
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
	
	// MARK: Market View [END] -
	
	var tabBarItems: some View {
		HStack(alignment: .bottom) {
			Spacer()
			MainTabViewItem(
				title: "Home",
				isSelected: currentSelection == .home,
				selectedContent: {
					Image.selectedHomeTabBarItem
						.resizable()
				},
				unselectedContent: {
					Image.homeTabBarItem
						.resizable()
				}
			)
			.onTapGesture {
				self.setSelection(to: .home)
			}
			Spacer()
			MainTabViewItem(
				title: "Market",
				isSelected: currentSelection == .market,
				selectedContent: {
					Image.selectedMarketTabBarItem
						.resizable()
						.scaleEffect(0.9)
						.offset(y: 4)
				},
				unselectedContent: {
					Image.marketTabBarItem
						.resizable()
						.scaleEffect(0.9)
						.offset(y: 4)
				}
			)
			.onTapGesture {
				self.setSelection(to: .market)
			}
			if !currentUser.decks.isEmpty {
				Spacer()
				MainTabViewItem(
					title: "Decks",
					isSelected: currentSelection == .decks,
					selectedContent: {
						DeckIcon<EmptyView>(
							color: .extraPurple
						)
						.offset(y: 2)
					},
					unselectedContent: {
						DeckIcon<EmptyView>(
							color: .unselectedTabBarItem
						)
						.offset(y: 2)
					}
				)
				.onTapGesture {
					self.setSelection(to: .decks)
				}
			}
			Spacer()
			MainTabViewItem(
				title: "You",
				isSelected: currentSelection == .profile,
				selectedContent: {
					Image.selectedProfileTabBarItem
						.resizable()
						.scaleEffect(0.9)
						.offset(y: 3)
				},
				unselectedContent: {
					Image.profileTabBarItem
						.resizable()
						.scaleEffect(0.9)
						.offset(y: 3)
				}
			)
			.onTapGesture {
				self.setSelection(to: .profile)
			}
			Spacer()
		}
	}
	
	var body: some View {
		NavigationView {
			SideBar {
				ZStack {
					VStack(spacing: 0) {
						ZStack {
							Color.lightGrayBackground
								.edgesIgnoringSafeArea([.horizontal, .top])
							SwitchOver(currentSelection)
								.case(.home) {
									HomeView()
								}
								.case(.market) {
									MarketView(
										searchText: $searchText,
										isSortPopUpShowing: $isSortPopUpShowing,
										isFilterPopUpShowing: $isFilterPopUpShowing,
										searchResults: searchResults,
										searchResultsLoadingState: searchResultsLoadingState,
										loadSearchResults: loadSearchResults
									)
								}
								.case(.decks) {
									DecksView()
										.environmentObject(decksViewModel)
								}
								.case(.profile) {
									ProfileView()
								}
							if currentStore.mainTabViewSelection == .home {
								VStack {
									PublishDeckViewNavigationLink {
										ZStack {
											Circle()
												.foregroundColor(.init(#colorLiteral(red: 0.262745098, green: 0.5294117647, blue: 0.9764705882, alpha: 1)))
												.overlay(
													Circle()
														.stroke(Color.lightGray)
												)
												.shadow(
													color: Color.black.opacity(0.3),
													radius: 10,
													y: 5
												)
												.frame(width: 64, height: 64)
											Image(systemName: .plus)
												.font(.largeTitle)
												.foregroundColor(.white)
										}
									}
									if currentStore.user.numberOfDueCards > 0 {
										FloatingReviewButton(user: currentStore.user)
									}
								}
								.opacity(0.95)
								.alignment(.bottomTrailing)
								.padding([.trailing, .bottom], 16)
							}
						}
						Rectangle()
							.fill(Color.lightGrayLine.opacity(0.5))
							.frame(height: 1)
						ZStack {
							Color.lightGray
								.edgesIgnoringSafeArea(.all)
							tabBarItems
						}
						.frame(height: 72)
					}
					MarketViewSortPopUp(
						isSortPopUpShowing: $isSortPopUpShowing,
						sortAlgorithm: $sortAlgorithm,
						loadSearchResults: loadSearchResults
					)
					MarketViewFilterPopUp(
						isFilterPopUpShowing: $isFilterPopUpShowing,
						topicsFilter: $topicsFilter,
						ratingFilter: $ratingFilter,
						downloadsFilter: $downloadsFilter,
						filterPopUpSideBarSelection: $filterPopUpSideBarSelection,
						loadSearchResults: loadSearchResults,
						isTopicSelected: isTopicSelected,
						toggleTopicSelect: toggleTopicSelect
					)
					if currentStore.selectedDeck != nil {
						DecksViewDeckOptionsPopUp(
							selectedDeck: currentStore.selectedDeck!
						)
						.environmentObject(decksViewModel)
						if decksViewModel.selectedSection != nil {
							DecksViewSectionOptionsPopUp(
								deck: currentStore.selectedDeck!,
								section: decksViewModel.selectedSection!
							)
							.environmentObject(decksViewModel)
						}
					}
				}
			}
			.navigationBarRemoved()
		}
		.onAppear {
			self.currentStore.initializeIfNeeded()
		}
	}
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
	static var previews: some View {
		PREVIEW_CURRENT_STORE.rootDestination
	}
}
#endif

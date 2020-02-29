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
	
	func setSelection(to selection: Selection) {
		currentStore.mainTabViewSelection = selection
	}
	
	var currentSelection: Selection {
		currentStore.mainTabViewSelection
	}
	
	// MARK: - Market View [START]
	
	@State var marketView_searchText = "" {
		didSet {
			marketView_switchSortAlgorithmIfNeeded()
			marketView_loadSearchResults(force: true)
		}
	}
	
	@State var marketView_isSortPopUpShowing = false
	@State var marketView_isFilterPopUpShowing = false

	@State var marketView_filterPopUpSideBarSelection = MarketView.FilterPopUpSideBarSelection.topics

	@State var marketView_sortAlgorithm = Deck.SortAlgorithm.recommended

	@State var marketView_topicsFilter: [Topic]? = nil {
		didSet {
			marketView_switchSortAlgorithmIfNeeded()
		}
	}
	
	@State var marketView_ratingFilter = 0.0 {
		didSet {
			marketView_switchSortAlgorithmIfNeeded()
		}
	}
	
	@State var marketView_downloadsFilter = 0.0 {
		didSet {
			marketView_switchSortAlgorithmIfNeeded()
		}
	}
	
	@State var marketView_searchResults = [Deck]()
	@State var marketView_searchResultsLoadingState = LoadingState()
	
	func marketView_setSearchText(_ searchText: String) {
		marketView_searchText = searchText
	}
	
	func marketView_switchSortAlgorithmIfNeeded() {
		if
			marketView_searchText.isEmpty &&
			marketView_topicsFilter == nil &&
			marketView_ratingFilter.isZero &&
			marketView_downloadsFilter.isZero
		{
			marketView_sortAlgorithm = .recommended
		} else if marketView_sortAlgorithm == .recommended {
			marketView_sortAlgorithm = .relevance
		}
	}
	
	var marketView_deckSearchRatingFilter: Double? {
		marketView_ratingFilter.isZero
			? nil
			: marketView_ratingFilter
	}
	
	var marketView_deckSearchDownloadsFilter: Int? {
		marketView_downloadsFilter.isZero
			? nil
			: .init(marketView_downloadsFilter)
	}
	
	var marketView_searchResultsPromise: Promise<[Deck]> {
		marketView_sortAlgorithm == .recommended
			? currentStore.user.recommendedDecks()
			: Deck.search(
				query: marketView_searchText,
				filterForTopics: marketView_topicsFilter?.map(~\.id),
				averageRatingGreaterThan: marketView_deckSearchRatingFilter,
				numberOfDownloadsGreaterThan: marketView_deckSearchDownloadsFilter,
				sortBy: marketView_sortAlgorithm
			)
	}
	
	func marketView_loadSearchResults(force: Bool) {
		guard force || marketView_searchResultsLoadingState.isNone else { return }
		marketView_searchResultsLoadingState.startLoading()
		self.marketView_searchResultsPromise.done { decks in
			self.marketView_searchResults = decks.map { $0.loadImage() }
			self.marketView_searchResultsLoadingState.succeed()
		}.catch { error in
			self.marketView_searchResultsLoadingState.fail(error: error)
			showAlert(title: "An error occurred", message: error.localizedDescription)
		}
	}
	
	func marketView_isTopicSelected(_ topic: Topic) -> Bool {
		marketView_topicsFilter?.contains(topic) ?? true
	}
	
	func marketView_toggleTopicSelect(_ topic: Topic) {
		marketView_isTopicSelected(topic)
			? marketView_topicsFilter?.removeAll { $0 == topic }
			: marketView_topicsFilter?.append(topic)
	}
	
	// MARK: Market View [END] -
	
	// MARK: - Decks View [START]
	
	@State var decksView_isDeckOptionsPopUpShowing = false
	
	@State var decksView_selectedSection: Deck.Section? = nil // swiftlint:disable:this redundant_optional_initialization
	@State var decksView_isSectionOptionsPopUpShowing = false
	
	@State var decksView_isDestroyAlertShowing = false
	@State var decksView_isOrderSectionsSheetShowing = false
	
	@State var decksView_expandedSections = [Deck.Section: Void]()
	
	func decksView_isSectionExpanded(_ section: Deck.Section) -> Bool {
		decksView_expandedSections[section] != nil
	}
	
	func decksView_toggleSectionExpanded(_ section: Deck.Section, forUser user: User) {
		if decksView_isSectionExpanded(section) {
			decksView_expandedSections[section] = nil
		} else {
			decksView_expandedSections[section] = ()
			section.loadCards(withUserDataForUser: user)
		}
	}
	
	// MARK: Decks View [END] -
	
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
										isSortPopUpShowing: $marketView_isSortPopUpShowing,
										isFilterPopUpShowing: $marketView_isFilterPopUpShowing,
										searchText: marketView_searchText,
										setSearchText: marketView_setSearchText,
										searchResults: marketView_searchResults,
										searchResultsLoadingState: marketView_searchResultsLoadingState,
										loadSearchResults: marketView_loadSearchResults
									)
								}
								.case(.decks) {
									DecksView(
										isDeckOptionsPopUpShowing: $decksView_isDeckOptionsPopUpShowing,
										selectedSection: $decksView_selectedSection,
										isSectionOptionsPopUpShowing: $decksView_isSectionOptionsPopUpShowing,
										isSectionExpanded: decksView_isSectionExpanded,
										toggleSectionExpanded: decksView_toggleSectionExpanded
									)
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
						isSortPopUpShowing: $marketView_isSortPopUpShowing,
						sortAlgorithm: $marketView_sortAlgorithm,
						loadSearchResults: marketView_loadSearchResults
					)
					MarketViewFilterPopUp(
						isFilterPopUpShowing: $marketView_isFilterPopUpShowing,
						topicsFilter: $marketView_topicsFilter,
						ratingFilter: $marketView_ratingFilter,
						downloadsFilter: $marketView_downloadsFilter,
						filterPopUpSideBarSelection: $marketView_filterPopUpSideBarSelection,
						loadSearchResults: marketView_loadSearchResults,
						isTopicSelected: marketView_isTopicSelected,
						toggleTopicSelect: marketView_toggleTopicSelect
					)
					if currentStore.selectedDeck != nil {
						DecksViewDeckOptionsPopUp(
							selectedDeck: currentStore.selectedDeck!,
							isDeckOptionsPopUpShowing: $decksView_isDeckOptionsPopUpShowing,
							isOrderSectionsSheetShowing: $decksView_isOrderSectionsSheetShowing
						)
						if decksView_selectedSection != nil {
							DecksViewSectionOptionsPopUp(
								deck: currentStore.selectedDeck!,
								section: decksView_selectedSection!,
								isSectionOptionsPopUpShowing: $decksView_isSectionOptionsPopUpShowing
							)
						}
					}
				}
			}
			.navigationBarRemoved()
		}
		.navigationViewStyle(StackNavigationViewStyle())
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

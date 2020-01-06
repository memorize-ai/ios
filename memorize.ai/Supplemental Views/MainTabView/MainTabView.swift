import SwiftUI
import SwiftUIX

struct MainTabView: View {
	enum Selection {
		case home
		case market
		case decks
		case profile
	}
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var currentUser: User
	
	@ObservedObject var marketViewModel: MarketViewModel
	@ObservedObject var decksViewModel = DecksViewModel()
	
	init(currentUser: User) {
		self.currentUser = currentUser
		marketViewModel = .init(currentUser: currentUser)
	}
		
	func setSelection(to selection: Selection) {
		currentStore.mainTabViewSelection = selection
	}
	
	var currentSelection: Selection {
		currentStore.mainTabViewSelection
	}
	
	var floatingReviewButtonXOffset: CGFloat {
		currentStore.user.numberOfDueCards > 0
			? 0
			: 100
	}
	
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
									MarketView()
										.environmentObject(marketViewModel)
								}
								.case(.decks) {
									DecksView()
										.environmentObject(decksViewModel)
								}
								.case(.profile) {
									ProfileView()
								}
							if currentStore.mainTabViewSelection == .home {
								FloatingReviewButton(user: currentStore.user)
									.align(to: .bottomTrailing)
									.padding([.trailing, .bottom], 16)
									.offset(x: floatingReviewButtonXOffset)
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
					MarketViewSortPopUp()
						.environmentObject(marketViewModel)
					MarketViewFilterPopUp()
						.environmentObject(marketViewModel)
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
			.removeNavigationBar()
		}
		.onAppear {
			self.currentStore.initializeIfNeeded()
		}
	}
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
	static var previews: some View {
		MainTabView(currentUser: PREVIEW_CURRENT_STORE.user)
			.environmentObject(PREVIEW_CURRENT_STORE)
			.removeNavigationBar()
	}
}
#endif

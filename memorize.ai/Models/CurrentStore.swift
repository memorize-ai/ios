import SwiftUI
import FirebaseFirestore
import PromiseKit
import LoadingState

final class CurrentStore: ObservableObject {
	@Published var user: User
	@Published var userLoadingState = LoadingState()
	
	@Published var topics: [Topic]
	@Published var topicsLoadingState = LoadingState()
	
	@Published var interestsLoadingState = LoadingState()
	@Published var topicLoadingState = LoadingState()
	
	@Published var recommendedDecks: [Deck]
	@Published var recommendedDecksLoadingState = LoadingState()
	
	@Published var signOutLoadingState = LoadingState()
	
	@Published var selectedDeck: Deck?
	
	@Published var mainTabViewSelection = MainTabView.Selection.home
	@Published var isSideBarShowing = false
	
	init(user: User, topics: [Topic] = [], recommendedDecks: [Deck] = []) {
		self.user = user
		self.topics = topics
		self.recommendedDecks = recommendedDecks
		
		initializeUser()
	}
	
	func initializeUser() {
		user.setOnDecksChange { decks, event in
			switch event {
			case let .added(deck: deck):
				guard decks.count == 1 else { return }
				self.selectedDeck = deck
			case let .removed(id: deckId):
				if decks.isEmpty && self.mainTabViewSelection == .decks {
					self.mainTabViewSelection = .home
					return
				}
				if self.selectedDeck?.id == deckId {
					self.selectedDeck = decks.first
				}
			}
		}
	}
	
	var interests: [Topic?] {
		var acc = [Topic?]()
		
		for topicId in user.interests {
			if (acc.contains { $0?.id == topicId }) { continue }
			acc.append(topics.first { $0.id == topicId })
		}
		
		return acc
	}
	
	var rootDestination: some View {
		MainTabView(currentUser: user)
			.environmentObject(self)
			.navigationBarRemoved()
	}
	
	@discardableResult
	func initializeIfNeeded() -> Self {
		loadUser()
		loadAllTopics()
		user.loadDecks()
		return self
	}
	
	@discardableResult
	func goToDecksView(withDeck deck: Deck) -> Self {
		withAnimation(SIDE_BAR_ANIMATION) {
			selectedDeck = deck.loadSections()
			isSideBarShowing = false
			mainTabViewSelection = .decks
		}
		return self
	}
	
	@discardableResult
	func reloadSelectedDeck() -> Self {
		selectedDeck = user.decks.first
		if selectedDeck == nil && mainTabViewSelection == .decks {
			mainTabViewSelection = .home
		}
		return self
	}
	
	@discardableResult
	func loadUser() -> Self {
		guard userLoadingState.isNone else { return self }
		userLoadingState.startLoading()
		onBackgroundThread {
			firestore.document("users/\(self.user.id)").addSnapshotListener { snapshot, error in
				guard error == nil, let snapshot = snapshot else {
					onMainThread {
						self.userLoadingState.fail(error: error ?? UNKNOWN_ERROR)
					}
					return
				}
				onMainThread {
					self.user.updateFromSnapshot(snapshot)
					self.userLoadingState.succeed()
					self.loadRecommendedDecks()
				}
			}
		}
		return self
	}
	
	@discardableResult
	func signOut() -> Self {
		if let error = auth.signOutWithError() {
			signOutLoadingState.fail(error: error)
		} else {
			signOutLoadingState.succeed()
		}
		return self
	}
	
	@discardableResult
	func loadAllTopics() -> Self {
		guard topicsLoadingState.isNone else { return self }
		topicsLoadingState.startLoading()
		onBackgroundThread {
			firestore.collection("topics").addSnapshotListener { snapshot, error in
				guard error == nil, let documentChanges = snapshot?.documentChanges else {
					onMainThread {
						self.topicsLoadingState.fail(error: error ?? UNKNOWN_ERROR)
					}
					return
				}
				for change in documentChanges {
					let document = change.document
					let topicId = document.documentID
					switch change.type {
					case .added:
						if (self.topics.contains { $0.id == topicId }) { continue }
						let topic = Topic(
							id: topicId,
							name: document.get("name") as? String ?? "Unknown",
							category: {
								guard let categoryString = document.get("category") as? String else {
									return .language
								}
								return Topic.Category(rawValue: categoryString) ?? .language
							}()
						)
						onMainThread {
							self.topics.append(topic.cache())
						}
					case .modified:
						if (self.topics.contains { $0.id == topicId }) { continue }
						onMainThread {
							self.topics.first { $0.id == topicId }?
								.updateFromSnapshot(document)
						}
					case .removed:
						onMainThread {
							self.topics.removeAll { $0.id == topicId }
						}
					}
				}
				onMainThread {
					self.topics.sort(by: \.name)
					self.topicsLoadingState.succeed()
				}
			}
		}
		return self
	}
	
	@discardableResult
	func loadRecommendedDecks() -> Self {
		guard recommendedDecksLoadingState.isNone else { return self }
		recommendedDecksLoadingState.startLoading()
		onBackgroundThread {
			self.user.recommendedDecks().done { decks in
				onMainThread {
					self.recommendedDecks = decks
					self.recommendedDecksLoadingState.succeed()
				}
			}.catch { error in
				onMainThread {
					self.recommendedDecksLoadingState.fail(error: error)
				}
			}
		}
		return self
	}
}

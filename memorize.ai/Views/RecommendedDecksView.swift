import SwiftUI

struct RecommendedDecksView: View {
	var body: some View {
		PostSignUpView(
			title: "Test",
			leadingButton: EmptyView(),
			trailingButtonTitle: "TEST",
			trailingButtonDestination: EmptyView(),
			content: TestView()
		)
	}
}

final class TestViewModel: ViewModel {
	@Published var decks = [Deck]()
	@Published var decksLoadingState = LoadingState.none
	
	var loadedDecks = [String]()
	
	func loadDecks(interests: [String], topics: [Topic]) {
		decksLoadingState = .loading()
		let maxDecksPerTopic = getMaxDecksPerTopic(
			numberOfInterests: interests.count
		)
		for topicId in interests {
			if decksLoadingState.didFail { return }
			print("TOPIC_ID: ", topicId)
			guard let topic = (topics.first {
				$0.id == topicId
			}) else { continue }
			print("DID_FIND_TOPIC_FOR_TOPIC_ID: ", topicId, "NAME: ", topic.name)
			for deckId in topic.topDecks.prefix(maxDecksPerTopic) where !didLoadDeck(id: deckId) {
				if decksLoadingState.didFail { return }
				loadedDecks.append(deckId)
				print("TOP_DECK_FOR_TOPIC_NAME: ", topic.name, "DECK_ID: ", deckId)
				loadDeck(id: deckId)
			}
		}
	}
	
	func loadDeck(id: String) {
		print("LOADING_DECK: ", id)
		Deck.fromId(id).done { deck in
			print("SUCCESSFUL_LOAD_DECK_ID: ", id, "NAME: ", deck.name)
			self.decks.append(deck)
			self.decksLoadingState = .success()
			print("DONE_LOADING_DECK_NAME: ", deck.name)
			print("DECKS_COUNT: ", self.decks.count)
		}.catch { error in
			self.decksLoadingState = .failure(
				message: error.localizedDescription
			)
			print("ERROR_LOADING_DECK_ID: ", id, "ERROR: ", error.localizedDescription)
		}
	}
	
	func getMaxDecksPerTopic(numberOfInterests: Int) -> Int {
		3 // TODO: Calculate this dynamically
	}
	
	func didLoadDeck(id: String) -> Bool {
		loadedDecks.contains(id)
	}
}

struct TestView: View {
	static let deckCellWidth: CGFloat = 165
	static let numberOfColumns =
		Int(SCREEN_SIZE.width) / Int(deckCellWidth)
	static let horizontalCellSpacing: CGFloat = 10
	static let verticalCellSpacing: CGFloat = 20
	
	@EnvironmentObject var currentUserStore: UserStore
	
	@ObservedObject var model = TestViewModel()
	
	var body: some View {
		print("VIEW_DECKS_COUNT:", model.decks.count)
		return ScrollView {
			Grid(
				elements: model.decks.map { deck in
					DeckCellWithGetButton(
						deck: deck,
						width: Self.deckCellWidth,
						isLoading: false, // TODO: Change this
						onGetClick: {} // TODO: Change this
					)
				},
				columns: Self.numberOfColumns,
				horizontalSpacing: Self.horizontalCellSpacing,
				verticalSpacing: Self.verticalCellSpacing
			)
			.frame(maxWidth: SCREEN_SIZE.width - 32)
		}
		.onAppear {
			guard self.model.decksLoadingState.isNone else { return }
			self.model.loadDecks(
				interests: self.currentUserStore.user.interests,
				topics: self.currentUserStore.topics
			)
		}
	}
}

#if DEBUG
struct RecommendedDecksView_Previews: PreviewProvider {
	static var previews: some View {
		RecommendedDecksView()
	}
}
#endif

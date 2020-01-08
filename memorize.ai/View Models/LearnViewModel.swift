import SwiftUI
import FirebaseFirestore
import LoadingState

final class LearnViewModel: ViewModel {
	static let popUpSlideDuration = 0.25
	
	let deck: Deck
	let section: Deck.Section?
	
	let numberOfTotalCards: Int
	
	@Published var current: Card.LearnData?
	@Published var currentIndex = -1
	@Published var currentSide = Card.Side.front
	
	@Published var isWaitingForRating = false
	
	@Published var isRecapSheetViewShowing = false
	
	@Published var popUpOffset: CGFloat = -SCREEN_SIZE.width
	@Published var popUpData: (emoji: String?, message: String)?
	
	@Published var currentCardLoadingState = LoadingState()
	
	var cards = [Card.LearnData]()
	var shouldShowRecap = false {
		didSet {
			isRecapSheetViewShowing = shouldShowRecap
		}
	}
	
	init(deck: Deck, section: Deck.Section?) {
		self.deck = deck
		self.section = section
		
		numberOfTotalCards = section?.numberOfCards ?? deck.numberOfCards
	}
	
	var currentCard: Card? {
		current?.parent
	}
	
	var isAllMastered: Bool {
		numberOfMasteredCards == numberOfTotalCards
	}
	
	var numberOfMasteredCards: Int {
		cards.reduce(0) { acc, card in
			acc + *card.isMastered
		}
	}
	
	var numberOfSeenCards: Int {
		cards.count - numberOfMasteredCards
	}
	
	var numberOfUnseenCards: Int {
		numberOfTotalCards - cards.count
	}
	
	var isPopUpShowing: Bool {
		popUpOffset.isZero
	}
	
	func showPopUp(
		emoji: String?,
		message: String,
		duration: Double = 1,
		completion: (() -> Void)? = nil
	) {
		popUpData = (emoji, message)
		withAnimation(.easeOut(duration: Self.popUpSlideDuration)) {
			popUpOffset = 0
		}
		Timer.scheduledTimer(
			withTimeInterval: Self.popUpSlideDuration + duration,
			repeats: false
		) { _ in
			withAnimation(.easeIn(duration: Self.popUpSlideDuration)) {
				self.popUpOffset = SCREEN_SIZE.width
			}
			Timer.scheduledTimer(
				withTimeInterval: Self.popUpSlideDuration,
				repeats: false
			) { _ in
				self.popUpOffset = -SCREEN_SIZE.width
				completion?()
			}
		}
	}
	
	func showPopUp(
		forRating rating: Card.PerformanceRating,
		completion: (() -> Void)? = nil
	) {
		switch rating {
		case .easy:
			switch true {
			case current?.isMastered:
				showPopUp(emoji: "🎉", message: "Mastered!", completion: completion)
			case current?.streak ?? 0 > 2:
				showPopUp(emoji: "🎉", message: "On a roll!", completion: completion)
			default:
				showPopUp(emoji: "🎉", message: "Great!", completion: completion)
			}
		case .struggled:
			showPopUp(emoji: "😎", message: "Good luck!", completion: completion)
		case .forgot:
			showPopUp(emoji: "😕", message: "Better luck next time!", completion: completion)
		}
	}
	
	func rateCurrentCard(withRating rating: Card.PerformanceRating) {
		current?.addRating(rating)
		withAnimation(.easeIn(duration: 0.3)) {
			isWaitingForRating = false
		}
		showPopUp(forRating: rating) {
			self.isAllMastered
				? self.shouldShowRecap = true
				: self.loadNextCard()
		}
	}
	
	func loadNextCard() {
		currentIndex =
			currentIndex == numberOfTotalCards - 1 ? 0 : currentIndex + 1
		
		if let section = section {
			if let card = cards[safe: currentIndex] {
				current = card
				currentSide = .front
			} else if let card = section.cards[safe: currentIndex] {
				let card = Card.LearnData(parent: card)
				cards.append(card)
				current = card
				currentSide = .front
			} else {
				currentCardLoadingState.startLoading()
				
				var query = deck.documentReference
					.collection("cards")
					.whereField("section", isEqualTo: section.id)
				
				if let currentCardSnapshot = currentCard?.snapshot {
					query = query.start(afterDocument: currentCardSnapshot)
				}
				
				query
					.limit(to: 1)
					.getDocuments()
					.done { snapshot in
						if let document = snapshot.documents.first {
							let card = Card.LearnData(
								parent: .init(snapshot: document)
							)
							self.cards.append(card)
							self.current = card
							self.currentSide = .front
						} else {
							self.shouldShowRecap = true
						}
						self.currentCardLoadingState.succeed()
					}
					.catch { error in
						print(error) // TODO: Handle error with alert
						self.currentCardLoadingState.fail(error: error)
					}
			}
		} else {
			
		}
	}
}

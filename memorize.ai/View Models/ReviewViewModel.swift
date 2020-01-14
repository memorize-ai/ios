import SwiftUI
import FirebaseFirestore
import PromiseKit
import LoadingState

final class ReviewViewModel: ViewModel {
	static let POP_UP_SLIDE_DURATION = 0.25
	static let CARD_SLIDE_DURATION = 0.25
	static let XP_CHANCE = 0.5
	
	enum CardRetrievalState {
		case seenCards
		case newCards
	}
	
	typealias PopUpData = (
		emoji: String,
		message: String,
		badge: (text: String, color: Color)?
	)
	
	let user: User
	let deck: Deck?
	let section: Deck.Section?
	
	let numberOfTotalCards: Int
	
	@Published var current: Card.ReviewData?
	@Published var currentIndex = -1
	@Published var currentSide = Card.Side.front
	
	@Published var isWaitingForRating = false
	
	@Published var shouldShowRecap = false
	
	@Published var popUpOffset: CGFloat = -SCREEN_SIZE.width
	@Published var popUpData: PopUpData?
	
	@Published var cardOffset: CGFloat = 0
	
	@Published var currentCardLoadingState = LoadingState()
	@Published var reviewCardLoadingState = LoadingState()
	
	@Published var xpGained = 0
	
	var isReviewingNewCards = false
	var cards = [Card.ReviewData]()
	var initialXP = 0
	
	init(user: User, deck: Deck?, section: Deck.Section?) {
		self.user = user
		self.deck = deck
		self.section = section
		
		numberOfTotalCards =
			section?.numberOfDueCards
				?? deck?.userData?.numberOfDueCards
					?? user.numberOfDueCards
	}
	
	var currentCard: Card? {
		current?.parent
	}
	
	var isPopUpShowing: Bool {
		popUpOffset.isZero
	}
	
	var shouldGainXP: Bool {
		.random(in: 0...1) <= Self.XP_CHANCE
	}
	
	@discardableResult
	func addXP() -> Promise<Void>? {
		guard shouldGainXP else { return nil }
		xpGained++
		return user.documentReference.updateData([
			"xp": FieldValue.increment(1.0)
		])
	}
	
	func showPopUp(
		emoji: String,
		message: String,
		badge: (text: String, color: Color)?,
		duration: Double = 1,
		onCentered: (() -> Void)? = nil,
		completion: (() -> Void)? = nil
	) {
		popUpData = (emoji, message, badge)
		withAnimation(.easeOut(duration: Self.POP_UP_SLIDE_DURATION)) {
			popUpOffset = 0
		}
		waitUntil(duration: Self.POP_UP_SLIDE_DURATION) {
			onCentered?()
			waitUntil(duration: duration) {
				withAnimation(.easeIn(duration: Self.POP_UP_SLIDE_DURATION)) {
					self.popUpOffset = SCREEN_SIZE.width
				}
				waitUntil(duration: Self.POP_UP_SLIDE_DURATION) {
					self.popUpOffset = -SCREEN_SIZE.width
					completion?()
				}
			}
		}
	}
	
	func showPopUp(
		forRating rating: Card.PerformanceRating,
		onCentered: (() -> Void)? = nil,
		completion: (() -> Void)? = nil
	) {
		let badge = current?.predictionMessageForRating(rating).map { text in
			(text, rating.badgeColor)
		}
		switch rating {
		case .easy:
			showPopUp(emoji: "🎉", message: "Great!", badge: badge, onCentered: onCentered, completion: completion)
		case .struggled:
			showPopUp(emoji: "😎", message: "Good luck!", badge: badge, onCentered: onCentered, completion: completion)
		case .forgot:
			showPopUp(emoji: "😕", message: "Better luck next time!", badge: badge, onCentered: onCentered, completion: completion)
		}
	}
	
	func skipCard() {
		withAnimation(.easeIn(duration: 0.3)) {
			isWaitingForRating = false
		}
		showPopUp(emoji: "😕", message: "Skipped!", badge: nil, onCentered: {
			self.loadNextCard()
		})
	}
	
	func waitForRating() {
		withAnimation(.easeIn(duration: 0.3)) {
			isWaitingForRating = true
		}
		withAnimation(.easeIn(duration: Self.CARD_SLIDE_DURATION)) {
			cardOffset = -SCREEN_SIZE.width
		}
		waitUntil(duration: Self.CARD_SLIDE_DURATION) {
			self.currentSide = .back
			self.cardOffset = SCREEN_SIZE.width
			withAnimation(.easeOut(duration: Self.CARD_SLIDE_DURATION)) {
				self.cardOffset = 0
			}
		}
	}
	
	func rateCurrentCard(withRating rating: Card.PerformanceRating) {
		guard let current = current else { return }
		let card = current.parent
		
		cards.append(current)
		
		reviewCardLoadingState.startLoading()
		functions.httpsCallable("reviewCard").call(data: [
			"deck": card.parent.id,
			"card": card.id,
			"rating": rating.rawValue,
			"viewTime": 0 // TODO: Calculate this
		]).done { _ in
			self.addXP()
			self.reviewCardLoadingState.succeed()
		}.catch { error in
			showAlert(title: "Unable to rate card", message: "Please try again")
			self.reviewCardLoadingState.fail(error: error)
		}
		
		withAnimation(.easeIn(duration: 0.3)) {
			isWaitingForRating = false
		}
		
		let shouldShowRecap = currentIndex == numberOfTotalCards - 1
		
		showPopUp(
			forRating: rating,
			onCentered: {
				if shouldShowRecap { return }
				self.loadNextCard()
			},
			completion: {
				guard shouldShowRecap else { return }
				self.shouldShowRecap = true
			}
		)
	}
	
	func failCurrentCardLoadingState(withError error: Error) {
		showAlert(title: "Unable to load card", message: "You will move on to the next card")
		currentCardLoadingState.fail(error: error)
		loadNextCard()
	}
	
	func updateCurrentCard(to card: Card) {
		current = Card.ReviewData(parent: card).loadPrediction()
		currentSide = .front
	}
	
	func loadNextCard(
		incrementCurrentIndex: Bool = true,
		startLoading: Bool = true,
		continueFromSnapshot: Bool = true
	) {
		if incrementCurrentIndex {
			currentIndex++
		}
		
		if let section = section { // Reviewing section
			if startLoading {
				currentCardLoadingState.startLoading()
			}
			
			let deck = section.parent
			
			func updateCurrentCard(withId cardId: String) {
				if
					section.cardsLoadingState.didSucceed,
					let card = (section.cards.first { $0.id == cardId })
				{
					self.updateCurrentCard(to: card)
				} else {
					firestore
						.document("decks/\(deck.id)/cards/\(cardId)")
						.getDocument()
						.done { snapshot in
							self.updateCurrentCard(to: .init(
								snapshot: snapshot,
								parent: deck
							))
						}
						.catch(failCurrentCardLoadingState)
				}
			}
			
			var query = user.documentReference
				.collection("decks/\(deck.id)/cards")
				.limit(to: 1)
				.whereField("section", isEqualTo: section.id)
			
			if continueFromSnapshot, let currentCardSnapshot = currentCard?.snapshot {
				query = query.start(afterDocument: currentCardSnapshot)
			}
			
			if isReviewingNewCards {
				query
					.whereField("new", isEqualTo: true)
					.getDocuments()
					.done { snapshot in
						if let cardId = snapshot.documents.first?.documentID {
							updateCurrentCard(withId: cardId)
						} else {
							self.shouldShowRecap = true
						}
					}
					.catch(failCurrentCardLoadingState)
			} else {
				query
					.whereField("new", isEqualTo: false)
					.whereField("due", isLessThanOrEqualTo: Date())
					.order(by: "due")
					.getDocuments()
					.done { snapshot in
						if let cardId = snapshot.documents.first?.documentID {
							updateCurrentCard(withId: cardId)
						} else {
							self.isReviewingNewCards = true
							self.loadNextCard(
								incrementCurrentIndex: false,
								startLoading: false,
								continueFromSnapshot: false
							)
						}
					}
					.catch(failCurrentCardLoadingState)
			}
		} else if let deck = deck { // Reviewing deck
			print(deck.name)
		} else { // Reviewing all
			print(user.name)
		}
	}
}

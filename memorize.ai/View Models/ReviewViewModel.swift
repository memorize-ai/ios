import SwiftUI
import LoadingState

final class ReviewViewModel: ViewModel {
	typealias PopUpData = (
		emoji: String,
		message: String,
		badge: (text: String, color: Color)?
	)
	
	static let popUpSlideDuration = 0.25
	static let cardSlideDuration = 0.25
	
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
	
	var isReviewingNewCards = false
	
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
	
	func showPopUp(
		emoji: String,
		message: String,
		badge: (text: String, color: Color)?,
		duration: Double = 1,
		onCentered: (() -> Void)? = nil,
		completion: (() -> Void)? = nil
	) {
		popUpData = (emoji, message, badge)
		withAnimation(.easeOut(duration: Self.popUpSlideDuration)) {
			popUpOffset = 0
		}
		waitUntil(duration: Self.popUpSlideDuration) {
			onCentered?()
			waitUntil(duration: duration) {
				withAnimation(.easeIn(duration: Self.popUpSlideDuration)) {
					self.popUpOffset = SCREEN_SIZE.width
				}
				waitUntil(duration: Self.popUpSlideDuration) {
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
		showPopUp(emoji: "😕", message: "Skipped!", badge: nil, onCentered: loadNextCard)
	}
	
	func waitForRating() {
		withAnimation(.easeIn(duration: 0.3)) {
			isWaitingForRating = true
		}
		withAnimation(.easeIn(duration: Self.cardSlideDuration)) {
			cardOffset = -SCREEN_SIZE.width
		}
		waitUntil(duration: Self.cardSlideDuration) {
			self.currentSide = .back
			self.cardOffset = SCREEN_SIZE.width
			withAnimation(.easeOut(duration: Self.cardSlideDuration)) {
				self.cardOffset = 0
			}
		}
	}
	
	func rateCurrentCard(withRating rating: Card.PerformanceRating) {
		guard let card = current?.parent else { return }
		reviewCardLoadingState.startLoading()
		functions.httpsCallable("reviewCard").call(data: [
			"deck": card.parent.id,
			"card": card.id,
			"rating": rating.rawValue,
			"viewTime": 0 // TODO: Calculate this
		]).done { _ in
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
	
	func loadNextCard() {
		currentIndex++
		
		// TODO: Load next card
	}
}

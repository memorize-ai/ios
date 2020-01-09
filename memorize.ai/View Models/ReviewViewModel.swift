import SwiftUI
import LoadingState

final class ReviewViewModel: ViewModel {
	static let popUpSlideDuration = 0.25
	static let cardSlideDuration = 0.25
	
	let user: User
	let deck: Deck?
	let section: Deck.Section?
	
	let numberOfTotalCards: Int
	
	@Published var currentCard: Card?
	@Published var currentIndex = -1
	@Published var currentSide = Card.Side.front
	
	@Published var isWaitingForRating = false
	
	@Published var shouldShowRecap = false
	
	@Published var popUpOffset: CGFloat = -SCREEN_SIZE.width
	@Published var popUpData: (emoji: String?, message: String)?
	
	@Published var cardOffset: CGFloat = 0
	
	@Published var currentCardLoadingState = LoadingState()
	
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
	
	var isPopUpShowing: Bool {
		popUpOffset.isZero
	}
	
	func showPopUp(
		emoji: String?,
		message: String,
		duration: Double = 1,
		onCentered: (() -> Void)? = nil,
		completion: (() -> Void)? = nil
	) {
		popUpData = (emoji, message)
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
		switch rating {
		case .easy:
			showPopUp(emoji: "🎉", message: "+TODO", onCentered: onCentered, completion: completion)
		case .struggled:
			showPopUp(emoji: "😎", message: "+TODO", onCentered: onCentered, completion: completion)
		case .forgot:
			showPopUp(emoji: "😕", message: "+TODO", onCentered: onCentered, completion: completion)
		}
	}
	
	func skipCard() {
		withAnimation(.easeIn(duration: 0.3)) {
			isWaitingForRating = false
		}
		showPopUp(emoji: "😕", message: "Skipped!", onCentered: loadNextCard)
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
	
	func loadNextCard() {
		currentIndex++
		
		// TODO: Load next card
	}
}

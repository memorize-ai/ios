import SwiftUI
import FirebaseFirestore
import LoadingState

final class LearnViewModel: ViewModel {
	static let popUpSlideDuration = 0.25
	static let cardSlideDuration = 0.25
	
	let deck: Deck
	let section: Deck.Section?
	
	let numberOfTotalCards: Int
	
	@Published var current: Card.LearnData?
	@Published var currentIndex = -1
	@Published var currentSide = Card.Side.front
	
	@Published var currentSectionIndex: Int
	@Published var currentSectionCardIndex = -1
	
	@Published var isWaitingForRating = false
	
	@Published var shouldShowRecap = false
	
	@Published var popUpOffset: CGFloat = -SCREEN_SIZE.width
	@Published var popUpData: (emoji: String?, message: String)?
	
	@Published var cardOffset: CGFloat = 0
	
	@Published var currentCardLoadingState = LoadingState()
	
	var cards = [Card.LearnData]()
	
	init(deck: Deck, section: Deck.Section?) {
		self.deck = deck
		self.section = section
		
		numberOfTotalCards = section?.numberOfCards ?? deck.numberOfCards
		currentSectionIndex = deck.hasUnsectionedCards ? -1 : 0
	}
	
	var currentCard: Card? {
		current?.parent
	}
	
	var currentSection: Deck.Section? {
		currentSectionIndex == -1
			? deck.unsectionedSection
			: deck.sections[safe: currentSectionIndex]
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
			switch true {
			case current?.isMastered:
				showPopUp(emoji: "🎉", message: "Mastered!", onCentered: onCentered, completion: completion)
			case current?.streak ?? 0 > 2:
				showPopUp(emoji: "🎉", message: "On a roll!", onCentered: onCentered, completion: completion)
			default:
				showPopUp(emoji: "🎉", message: "Great!", onCentered: onCentered, completion: completion)
			}
		case .struggled:
			showPopUp(emoji: "😎", message: "Good luck!", onCentered: onCentered, completion: completion)
		case .forgot:
			showPopUp(emoji: "😕", message: "Better luck next time!", onCentered: onCentered, completion: completion)
		}
	}
	
	func skipCard() {
		withAnimation(.easeIn(duration: 0.3)) {
			isWaitingForRating = false
		}
		showPopUp(emoji: "😕", message: "Skipped!", onCentered: {
			self.loadNextCard()
		})
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
		current?.addRating(rating)
		withAnimation(.easeIn(duration: 0.3)) {
			isWaitingForRating = false
		}
		showPopUp(
			forRating: rating,
			onCentered: {
				if self.isAllMastered { return }
				self.loadNextCard()
			},
			completion: {
				guard self.isAllMastered else { return }
				self.shouldShowRecap = true
			}
		)
	}
	
	func incrementCurrentIndex() {
		currentIndex =
			currentIndex == numberOfTotalCards - 1 ? 0 : currentIndex + 1
	}
	
	func incrementCurrentSectionIndex() {
		guard let currentSection = currentSection else {
			if deck.hasUnsectionedCards {
				currentSectionIndex = -1
			} else {
				for i in 0..<deck.sections.count {
					if deck.sections[i].numberOfCards > 0 {
						currentSectionIndex = i
						break
					}
				}
			}
			return
		}
		if currentSectionCardIndex == currentSection.numberOfCards - 1 {
			if currentSectionIndex == deck.sections.count - 1 {
				if deck.hasUnsectionedCards {
					currentSectionIndex = -1
				} else {
					for i in 0..<deck.sections.count {
						if deck.sections[i].numberOfCards > 0 {
							currentSectionIndex = i
							break
						}
					}
				}
			} else {
				var didSetCurrentSectionIndex = false
				for i in currentSectionIndex + 1..<deck.sections.count {
					if deck.sections[i].numberOfCards > 0 {
						currentSectionIndex = i
						didSetCurrentSectionIndex = true
						break
					}
				}
				if !didSetCurrentSectionIndex {
					for i in 0..<deck.sections.count {
						if deck.sections[i].numberOfCards > 0 {
							currentSectionIndex = i
							break
						}
					}
				}
			}
			currentSectionCardIndex = 0
		} else {
			currentSectionCardIndex++
		}
	}
	
	func loadNextCard(incrementCurrentIndex shouldIncrement: Bool = true) {
		if shouldIncrement {
			incrementCurrentIndex()
		}
		
		if let section = section {
			if let card = cards[safe: currentIndex] {
				if card.isMastered { return loadNextCard() }
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
						showAlert(title: "Unable to load card", message: "Please try again")
						self.currentCardLoadingState.fail(error: error)
					}
			}
		} else if deck.sectionsLoadingState.didSucceed {
			incrementCurrentSectionIndex()
			
			guard let currentSection = currentSection else { return }
			
			if let card = cards[safe: currentIndex] {
				if card.isMastered { return loadNextCard() }
				current = card
				currentSide = .front
			} else if let card = currentSection.cards[safe: currentSectionCardIndex] {
				let card = Card.LearnData(parent: card)
				cards.append(card)
				current = card
				currentSide = .front
			} else {
				currentCardLoadingState.startLoading()
				
				var query = deck.documentReference
					.collection("cards")
					.whereField("section", isEqualTo: currentSection.id)
				
				if
					let currentCard = currentCard,
					currentCard.sectionId == currentSection.id,
					let currentCardSnapshot = currentCard.snapshot
				{
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
						showAlert(title: "Unable to load card", message: "Please try again")
						self.currentCardLoadingState.fail(error: error)
					}
			}
		} else {
			currentCardLoadingState.startLoading()
			deck.loadSections { error in
				if let error = error {
					showAlert(title: "Unable to load card", message: "Please try again")
					self.currentCardLoadingState.fail(error: error)
				} else {
					self.loadNextCard(incrementCurrentIndex: false)
					self.currentCardLoadingState.succeed()
				}
			}
		}
	}
}

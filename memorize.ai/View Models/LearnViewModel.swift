import SwiftUI
import FirebaseFirestore
import PromiseKit
import LoadingState

final class LearnViewModel: ViewModel {
	static let POP_UP_SLIDE_DURATION = 0.25
	static let CARD_SLIDE_DURATION = 0.25
	static let XP_CHANCE = 0.2
	
	typealias PopUpData = (
		emoji: String,
		message: String,
		badge: (text: String, color: Color)?
	)
	
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
	@Published var popUpData: PopUpData?
	
	@Published var cardOffset: CGFloat = 0
	
	@Published var currentCardLoadingState = LoadingState()
	
	@Published var xpGained = 0
	
	var cards = [Card.LearnData]()
	var initialXP = 0
	
	init(deck: Deck, section: Deck.Section?) {
		self.deck = deck
		self.section = section
		
		numberOfTotalCards = section?.numberOfCards ?? deck.numberOfUnlockedCards
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
	
	var shouldGainXP: Bool {
		.random(in: 0...1) <= Self.XP_CHANCE
	}
	
	@discardableResult
	func addXP(toUser user: User) -> Promise<Void>? {
		guard shouldGainXP else { return nil }
		xpGained++
		return user.documentReference.updateData([
			"xp": FieldValue.increment(1.0)
		])
	}
	
	func totalRatingCount(forRating rating: Card.PerformanceRating) -> Int {
		cards.reduce(0) { acc, card in
			acc + card.ratings.filter { $0 == rating }.count
		}
	}
	
	func reviewedCardsForSection(_ section: Deck.Section) -> [Card.LearnData] {
		cards.filter { card in
			section.contains(card: card.parent) &&
			!card.ratings.isEmpty
		}
	}
	
	func numberOfReviewedCardsForSection(_ section: Deck.Section) -> Int {
		reviewedCardsForSection(section).count
	}
	
	func frequentSections(forRating rating: Card.PerformanceRating) -> [Deck.Section] {
		([deck.unsectionedSection] + deck.unlockedSections).filter { section in
			let cards = reviewedCardsForSection(section)
			
			if cards.isEmpty { return false }
			
			return cards.reduce(0) { acc, card in
				switch rating {
				case .easy:
					return acc + *(card.mostFrequentRating == .easy)
				case .struggled, .forgot:
					return acc + *(card.countOfRating(rating) > card.ratings.count / 3)
				}
			} > numberOfReviewedCardsForSection(section) / 3
		}
	}
	
	func frequentCards(forRating rating: Card.PerformanceRating) -> [Card.LearnData] {
		cards.filter { card in
			if card.ratings.isEmpty { return false }
			switch rating {
			case .easy:
				return card.mostFrequentRating == .easy
			case .struggled, .forgot:
				return card.countOfRating(rating) > card.ratings.count / 3
			}
		}
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
		switch rating {
		case .easy:
			let badge = current.map { current in
				("\(current.streak)x streak", Color.neonGreen.opacity(0.16))
			}
			switch true {
			case current?.isMastered:
				showPopUp(emoji: "🎉", message: "Mastered!", badge: badge, onCentered: onCentered, completion: completion)
			case current?.streak ?? 0 > 2:
				showPopUp(emoji: "🎉", message: "On a roll!", badge: badge, onCentered: onCentered, completion: completion)
			default:
				showPopUp(emoji: "🎉", message: "Great!", badge: badge, onCentered: onCentered, completion: completion)
			}
		case .struggled:
			showPopUp(emoji: "😎", message: "Good luck!", badge: nil, onCentered: onCentered, completion: completion)
		case .forgot:
			showPopUp(emoji: "😕", message: "Better luck next time!", badge: nil, onCentered: onCentered, completion: completion)
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
	
	func rateCurrentCard(withRating rating: Card.PerformanceRating, user: User) {
		current?.addRating(rating)
		addXP(toUser: user)
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
				for i in 0..<deck.unlockedSections.count {
					if deck.unlockedSections[i].numberOfCards > 0 {
						currentSectionIndex = i
						break
					}
				}
			}
			return
		}
		if currentSectionCardIndex == currentSection.numberOfCards - 1 {
			if currentSectionIndex == deck.unlockedSections.count - 1 {
				if deck.hasUnsectionedCards {
					currentSectionIndex = -1
				} else {
					for i in 0..<deck.unlockedSections.count {
						if deck.unlockedSections[i].numberOfCards > 0 {
							currentSectionIndex = i
							break
						}
					}
				}
			} else {
				var didSetCurrentSectionIndex = false
				for i in currentSectionIndex + 1..<deck.unlockedSections.count {
					if deck.unlockedSections[i].numberOfCards > 0 {
						currentSectionIndex = i
						didSetCurrentSectionIndex = true
						break
					}
				}
				if !didSetCurrentSectionIndex {
					for i in 0..<deck.unlockedSections.count {
						if deck.unlockedSections[i].numberOfCards > 0 {
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
								parent: .init(snapshot: document, parent: self.deck)
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
						showAlert(title: "Unable to load card", message: "You will move on to the next card")
						self.currentCardLoadingState.fail(error: error)
						self.loadNextCard()
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
								parent: .init(snapshot: document, parent: self.deck)
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
						showAlert(title: "Unable to load card", message: "You will move on to the next card")
						self.currentCardLoadingState.fail(error: error)
						self.loadNextCard()
					}
			}
		} else {
			currentCardLoadingState.startLoading()
			deck.loadSections { error in
				if let error = error {
					showAlert(title: "Unable to load card", message: "You will move on to the next card")
					self.currentCardLoadingState.fail(error: error)
					self.loadNextCard()
				} else {
					self.loadNextCard(incrementCurrentIndex: false)
					self.currentCardLoadingState.succeed()
				}
			}
		}
	}
}

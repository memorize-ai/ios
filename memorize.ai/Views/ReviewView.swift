import SwiftUI
import FirebaseFirestore
import LoadingState

struct ReviewView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	static let POP_UP_SLIDE_DURATION = 0.25
	static let CARD_SLIDE_DURATION = 0.25
	static let XP_CHANCE = 0.5
	
	typealias PopUpData = (
		emoji: String,
		message: String,
		badges: [PopUpBadge]
	)
	
	struct PopUpBadge: Identifiable {
		let id = UUID()
		let text: String
		let color: Color
	}
	
	let user: User
	let deck: Deck?
	let section: Deck.Section?
	
	@State var numberOfTotalCards = 0
	
	@State var current: Card.ReviewData?
	@State var currentIndex = -1
	@State var currentSide = Card.Side.front
	
	@State var currentDeck: Deck?
	@State var currentSection: Deck.Section?
	
	@State var startDate: Date?
	
	@State var isWaitingForRating = false
	
	@State var shouldShowRecap = false
	
	@State var popUpOffset: CGFloat = -SCREEN_SIZE.width
	@State var popUpData: PopUpData?
	
	@State var cardOffset: CGFloat = 0
	
	@State var currentCardLoadingState = LoadingState()
	@State var reviewCardLoadingState = LoadingState()
	
	@State var xpGained = 0
	
	@State var isReviewingNewCards = false
	@State var cards = [Card.ReviewData]()
	@State var initialXP = 0
	
	init(user: User, deck: Deck?, section: Deck.Section?) {
		self.user = user
		self.deck = deck
		self.section = section
		
		_currentSection = .init(initialValue: deck?.unsectionedSection)
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
	
	var decks: [Deck]? {
		deck == nil
			? .init(Set(cards.reduce([]) { acc, card in
				acc + [card.parent.parent]
			}))
			: nil
	}
	
	var numberOfNewlyMasteredCards: Int {
		cards.reduce(0) { acc, card in
			acc + *(card.isNewlyMastered ?? false)
		}
	}
	
	var numberOfNewCards: Int {
		cards.reduce(0) { acc, card in
			acc + *card.isNew
		}
	}
	
	var recapView: some View {
		ReviewRecapView(
			decks: decks,
			deck: deck,
			section: section,
			xpGained: xpGained,
			initialXP: initialXP,
			totalEasyRatingCount: totalRatingCount(forRating: .easy),
			totalStruggledRatingCount: totalRatingCount(forRating: .struggled),
			totalForgotRatingCount: totalRatingCount(forRating: .forgot),
			numberOfNewlyMasteredCards: numberOfNewlyMasteredCards,
			numberOfNewCards: numberOfNewCards,
			frequentDecksForRating: { _ in [] }, // TODO: Get frequent decks for rating
			countOfCardsForDeck: countOfCardsForDeck,
			countOfRatingForDeck: countOfRatingForDeck,
			deckHasNewCards: deckHasNewCards,
			frequentSectionsForRating: { _ in [] }, // TODO: Get frequent sections for rating
			countOfCardsForSection: countOfCardsForSection,
			countOfRatingForSection: countOfRatingForSection,
			sectionHasNewCards: sectionHasNewCards,
			cardsForRating: cardsForRating
		)
		.environmentObject(currentStore)
		.navigationBarRemoved()
	}
	
	func countOfCardsForDeck(_ deck: Deck) -> Int {
		cards.reduce(0) { acc, card in
			acc + *(card.parent.parent == deck)
		}
	}
	
	func countOfRatingForDeck(_ deck: Deck, rating: Card.PerformanceRating) -> Int {
		cards
			.filter { $0.parent.parent == deck }
			.reduce(0) { acc, card in
				acc + *(card.rating == rating)
			}
	}
	
	func deckHasNewCards(_ deck: Deck) -> Bool {
		for card in cards where card.parent.parent == deck {
			if card.isNew {
				return true
			}
		}
		return false
	}
	
	func countOfCardsForSection(_ section: Deck.Section) -> Int {
		cards.reduce(0) { acc, card in
			acc + *section.contains(card: card.parent)
		}
	}
	
	func countOfRatingForSection(_ section: Deck.Section, rating: Card.PerformanceRating) -> Int {
		cards
			.filter { section.contains(card: $0.parent) }
			.reduce(0) { acc, card in
				acc + *(card.rating == rating)
			}
	}
	
	func sectionHasNewCards(_ section: Deck.Section) -> Bool {
		for card in cards where section.contains(card: card.parent) {
			if card.isNew {
				return true
			}
		}
		return false
	}
	
	func cardsForRating(_ rating: Card.PerformanceRating) -> [Card.ReviewData] {
		cards.filter { $0.rating == rating }
	}
	
	func totalRatingCount(forRating rating: Card.PerformanceRating) -> Int {
		cards.reduce(0) { acc, card in
			acc + *(card.rating == rating)
		}
	}
	
	func loadNumberOfTotalCards() {
		numberOfTotalCards =
			section?.numberOfDueCards
				?? deck?.userData?.numberOfDueCards
					?? user.numberOfDueCards
	}
	
	func loadCurrentDeck() {
		currentDeck = user.decks.first
		currentSection = currentDeck?.unsectionedSection
	}
	
	func showPopUp(
		emoji: String,
		message: String,
		badges: [PopUpBadge] = [],
		duration: Double = 1,
		onCentered: (() -> Void)? = nil,
		completion: (() -> Void)? = nil
	) {
		popUpData = (emoji, message, badges)
		withAnimation(.easeOut(duration: Self.POP_UP_SLIDE_DURATION)) {
			popUpOffset = 0
		}
		withDelay(Self.POP_UP_SLIDE_DURATION) {
			onCentered?()
			withDelay(duration) {
				withAnimation(.easeIn(duration: Self.POP_UP_SLIDE_DURATION)) {
					self.popUpOffset = SCREEN_SIZE.width
				}
				withDelay(Self.POP_UP_SLIDE_DURATION) {
					self.popUpOffset = -SCREEN_SIZE.width
					completion?()
				}
			}
		}
	}
	
	func showPopUp(
		forRating rating: Card.PerformanceRating,
		didGainXP: Bool,
		streak: Int,
		onCentered: (() -> Void)? = nil,
		completion: (() -> Void)? = nil
	) {
		let badges = [
			didGainXP
				? PopUpBadge(text: "+1 xp", color: Card.PerformanceRating.easy.badgeColor.opacity(0.16))
				: nil,
			PopUpBadge(
				text: "\(streak)/\(Card.ReviewData.NUMBER_OF_CONSECUTIVE_CORRECT_ATTEMPTS_FOR_MASTERED) streak",
				color: (streak == 0 ? Card.PerformanceRating.forgot : Card.PerformanceRating.easy).badgeColor.opacity(0.16)
			)
		].compactMap { $0 }
		
		switch rating {
		case .easy:
			switch true {
			case streak >= Card.ReviewData.NUMBER_OF_CONSECUTIVE_CORRECT_ATTEMPTS_FOR_MASTERED:
				showPopUp(emoji: "🎉", message: "Mastered!", badges: badges, onCentered: onCentered, completion: completion)
			case streak > 2:
				showPopUp(emoji: "🎉", message: "On a roll!", badges: badges, onCentered: onCentered, completion: completion)
			default:
				showPopUp(emoji: "🎉", message: "Great!", badges: badges, onCentered: onCentered, completion: completion)
			}
			showPopUp(emoji: "🎉", message: "Great!", badges: badges, onCentered: onCentered, completion: completion)
		case .struggled:
			showPopUp(emoji: "😎", message: "Good luck!", badges: badges, onCentered: onCentered, completion: completion)
		case .forgot:
			showPopUp(emoji: "😕", message: "Better luck next time!", badges: badges, onCentered: onCentered, completion: completion)
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
		withAnimation(.easeIn(duration: Self.CARD_SLIDE_DURATION)) {
			cardOffset = -SCREEN_SIZE.width
		}
		withDelay(Self.CARD_SLIDE_DURATION) {
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
		
		current.setRating(to: rating)
		cards.append(current)
		
		let gainXP = shouldGainXP
		
		if gainXP {
			xpGained++
		}
		
		let shouldShowRecap = currentIndex == numberOfTotalCards - 1
		
		reviewCardLoadingState.startLoading()
		card.review(
			rating: rating,
			viewTime: startDate.map { Date().timeIntervalSince($0) * 1000 } ?? 0 // Multiply by 1000 for milliseconds
		).done { isNewlyMastered in
			current.isNewlyMastered = isNewlyMastered
			self.reviewCardLoadingState.succeed()
			
			// After the card has been reviewed, load the next card if the recap should not be shown yet
			if shouldShowRecap { return }
			self.loadNextCard()
		}.catch { error in
			showAlert(title: "Unable to rate card", message: "You will move on to the next card")
			self.reviewCardLoadingState.fail(error: error)
			self.loadNextCard()
		}
		
		withAnimation(.easeIn(duration: 0.3)) {
			isWaitingForRating = false
		}
		
		showPopUp(
			forRating: rating,
			didGainXP: gainXP,
			streak: current.streak,
			completion: {
				if gainXP {
					self.user.documentReference.updateData([
						"xp": FieldValue.increment(1 as Int64)
					]) as Void
				}
				
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
	
	func updateCurrentCard(to card: Card, userData: Card.UserData?) {
		current = Card.ReviewData(
			parent: card,
			userData: userData
		).loadPrediction()
		currentSide = .front
		currentCardLoadingState.succeed()
		
		// Set the start time to now
		startDate = .now
	}
	
	func loadNextCard(
		incrementCurrentIndex: Bool = true,
		startLoading: Bool = true,
		continueFromSnapshot: Bool = true
	) {
		if incrementCurrentIndex {
			currentIndex++
		}
		
		if startLoading {
			currentCardLoadingState.startLoading()
		}
		
		if let section = section {
			// MARK: - Reviewing single section
			
			let deck = section.parent
			
			// Updates the current card by searching for it in the current section.
			// If the card hasn't been loaded yet, it loads it and then updates the current card.
			func updateCurrentCard(withId cardId: String, userData: Card.UserData?) {
				if let card = (section.cards.first { $0.id == cardId }) {
					// Found the card in the section
					self.updateCurrentCard(to: card, userData: userData)
				} else {
					// Load the card
					firestore
						.document("decks/\(deck.id)/cards/\(cardId)")
						.getDocument()
						.done { snapshot in
							self.updateCurrentCard(
								to: .init(
									snapshot: snapshot,
									parent: deck
								),
								userData: userData
							)
						}
						.catch(failCurrentCardLoadingState)
				}
			}
			
			if isReviewingNewCards {
				// Load the next card in the current section where "new" = true
				user.documentReference
					.collection("decks/\(deck.id)/cards")
					.whereField("section", isEqualTo: section.id)
					.whereField("new", isEqualTo: true)
					.start(afterDocument: continueFromSnapshot && (current?.isNew ?? false) ? currentCard?.snapshot : nil)
					.limit(to: 1)
					.getDocuments()
					.done { snapshot in
						if let cardId = snapshot.documents.first?.documentID {
							// There is a card, so update the current card
							updateCurrentCard(withId: cardId, userData: nil)
						} else {
							// There are no more cards in the section. Now, show the recap.
							self.shouldShowRecap = true
						}
					}
					.catch(failCurrentCardLoadingState)
			} else {
				// Load the next card in the current section where "new" = false and the card is due.
				// Then, sort by the due date ASCENDING
				user.documentReference
					.collection("decks/\(deck.id)/cards")
					.whereField("section", isEqualTo: section.id)
					.whereField("new", isEqualTo: false)
					.whereField("due", isLessThanOrEqualTo: Date())
					.order(by: "due")
					.start(afterDocument: continueFromSnapshot && !(current?.isNew ?? true) ? currentCard?.snapshot : nil)
					.limit(to: 1)
					.getDocuments()
					.done { snapshot in
						if let userData = snapshot.documents.first.map(Card.UserData.init) {
							// There is a card, so update the current card
							updateCurrentCard(withId: userData.id, userData: userData)
						} else {
							// There are no more non-new cards in the section, so transition to reviewing new cards
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
		} else if let deck = deck {
			// MARK: - Reviewing entire deck
			
			// This should never happen, but if it does, then show the recap
			guard let currentSection = currentSection else {
				self.shouldShowRecap = true
				return
			}
			
			// Load all of the current deck's sections if they haven't been loaded already.
			// Don't progress further until the deck's sections have been loaded successfully.
			guard deck.sectionsLoadingState.didSucceed else {
				deck.loadSections { error in
					if let error = error {
						self.failCurrentCardLoadingState(withError: error)
					} else {
						// Successfully loaded sections, now call the function again
						self.loadNextCard(
							incrementCurrentIndex: false,
							startLoading: false,
							continueFromSnapshot: continueFromSnapshot
						)
					}
				}
				return
			}
			
			// Updates the current section (which has been loaded by now), also the current card.
			func updateCurrentCard(withId cardId: String, sectionId: String, userData: Card.UserData?) {
				self.currentSection = deck.section(withId: sectionId)
				
				if let card = deck.card(withId: cardId, sectionId: sectionId) {
					// Found the card in the section, so update it immediately
					self.updateCurrentCard(to: card, userData: userData)
				} else {
					// Load the card on the spot
					firestore
						.document("decks/\(deck.id)/cards/\(cardId)")
						.getDocument()
						.done { snapshot in
							self.updateCurrentCard(
								to: .init(
									snapshot: snapshot,
									parent: deck
								),
								userData: userData
							)
						}
						.catch(failCurrentCardLoadingState)
				}
			}
			
			if isReviewingNewCards {
				// Load all cards in the current section where "new" = true
				user.documentReference
					.collection("decks/\(deck.id)/cards")
					.whereField("section", isEqualTo: currentSection.id)
					.whereField("new", isEqualTo: true)
					.start(afterDocument: continueFromSnapshot && (current?.isNew ?? false) ? currentCard?.snapshot : nil)
					.limit(to: 1)
					.getDocuments()
					.done { snapshot in
						if let cardId = snapshot.documents.first?.documentID {
							// There was another card in the current section, so update the current card
							updateCurrentCard(
								withId: cardId,
								sectionId: currentSection.id,
								userData: nil
							)
						} else {
							// There were no more cards in the current section, so update the current section
							func setCurrentSection(to section: Deck.Section) {
								self.currentSection = section
								self.loadNextCard(
									incrementCurrentIndex: false,
									startLoading: false,
									continueFromSnapshot: false
								)
							}
							
							let unlockedSections = deck.unlockedSections
							
							if currentSection.isUnsectioned {
								// If the current section is unsectioned, then get the first section
								if let newCurrentSection = unlockedSections.first {
									setCurrentSection(to: newCurrentSection)
								} else {
									// If there are no other sections, show the recap
									self.shouldShowRecap = true
								}
							} else if
								let currentSectionIndex = unlockedSections.firstIndex(of: currentSection),
								let newCurrentSection = unlockedSections[safe: currentSectionIndex + 1]
							{
								// There was a section after the current section
								setCurrentSection(to: newCurrentSection)
							} else {
								// This was the last section, so show the recap
								self.shouldShowRecap = true
							}
						}
					}
					.catch(failCurrentCardLoadingState)
			} else {
				// Load the next card where "new" = false, and the card is due.
				// Also, sort by the due date ASCENDING
				user.documentReference
					.collection("decks/\(deck.id)/cards")
					.whereField("new", isEqualTo: false)
					.whereField("due", isLessThanOrEqualTo: Date())
					.order(by: "due")
					.start(afterDocument: continueFromSnapshot && !(current?.isNew ?? true) ? currentCard?.snapshot : nil)
					.limit(to: 1)
					.getDocuments()
					.done { snapshot in
						if let userData = snapshot.documents.first.map(Card.UserData.init) {
							// There was another card that was not new, so update the current card with it
							updateCurrentCard(
								withId: userData.id,
								sectionId: userData.sectionId,
								userData: userData
							)
						} else {
							// There were no more non-new cards, so transition to new cards
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
		} else {
			// MARK: - Review all decks
			
			// 1. Review first deck's non-new cards, then the second deck's non-new cards and so on
			// 2. Review first decks's new cards, then the second deck's new cards
			
			// This should never happen, but if it does, then show the recap
			guard let currentDeck = currentDeck, let currentSection = currentSection else {
				self.shouldShowRecap = true
				return
			}
			
			// Load all of the current deck's sections if they haven't been loaded already.
			// Don't progress further until the deck's sections have been loaded successfully.
			guard currentDeck.sectionsLoadingState.didSucceed else {
				currentDeck.loadSections { error in
					if let error = error {
						self.failCurrentCardLoadingState(withError: error)
					} else {
						// Successfully loaded sections, now call the function again
						self.loadNextCard(
							incrementCurrentIndex: false,
							startLoading: false,
							continueFromSnapshot: continueFromSnapshot
						)
					}
				}
				return
			}
			
			// Updates the current section and the current card.
			func updateCurrentCard(withId cardId: String, sectionId: String, userData: Card.UserData?) {
				self.currentSection = currentDeck.section(withId: sectionId)
				
				if let card = currentDeck.card(withId: cardId, sectionId: sectionId) {
					// Found the card in the current deck, now update the current card with it
					self.updateCurrentCard(to: card, userData: userData)
				} else {
					// The card hasn't been loaded yet, so load it on the spot
					firestore
						.document("decks/\(currentDeck.id)/cards/\(cardId)")
						.getDocument()
						.done { snapshot in
							self.updateCurrentCard(
								to: .init(
									snapshot: snapshot,
									parent: currentDeck
								),
								userData: userData
							)
						}
						.catch(failCurrentCardLoadingState)
				}
			}
			
			if isReviewingNewCards {
				// Load the next card in the current section where "new" = true
				user.documentReference
					.collection("decks/\(currentDeck.id)/cards")
					.whereField("section", isEqualTo: currentSection.id)
					.whereField("new", isEqualTo: true)
					.start(afterDocument: continueFromSnapshot && (current?.isNew ?? false) ? currentCard?.snapshot : nil)
					.limit(to: 1)
					.getDocuments()
					.done { snapshot in
						if let cardId = snapshot.documents.first?.documentID {
							// There was another card, so update the current card with it
							updateCurrentCard(
								withId: cardId,
								sectionId: currentSection.id,
								userData: nil
							)
						} else {
							// There were no more cards in the current section,
							// so try to increment the current section
							
							func setCurrentSection(to section: Deck.Section) {
								self.currentSection = section
								self.loadNextCard(
									incrementCurrentIndex: false,
									startLoading: false,
									continueFromSnapshot: false
								)
							}
							
							func progressToNextDeck() {
								// Try to find the deck after the current deck
								guard
									let currentDeckIndex = self.user.decks.firstIndex(of: currentDeck),
									let newCurrentDeck = self.user.decks[safe: currentDeckIndex + 1]
								else {
									// This was the last deck, so show the recap
									self.shouldShowRecap = true
									return
								}
								
								// Successfully found the next deck, so update the current deck with it
								self.currentDeck = newCurrentDeck
								
								// Also, reset the current section so you start from the beginning with the current deck
								self.currentSection = newCurrentDeck.unsectionedSection
								
								// Call the function again with the new deck and section
								self.loadNextCard(
									incrementCurrentIndex: false,
									startLoading: false,
									continueFromSnapshot: false
								)
							}
							
							// Only look through the unlocked sections
							let unlockedSections = currentDeck.unlockedSections
							
							if currentSection.isUnsectioned {
								// If the current section is unsectioned, get the first section
								if let newCurrentSection = unlockedSections.first {
									setCurrentSection(to: newCurrentSection)
								} else {
									// There were no other sections in the deck, so move on to the next deck
									progressToNextDeck()
								}
							} else if
								let currentSectionIndex = unlockedSections.firstIndex(of: currentSection),
								let newCurrentSection = unlockedSections[safe: currentSectionIndex + 1]
							{
								// Found a section in the current deck after the current section,
								// so update the current section with it
								setCurrentSection(to: newCurrentSection)
							} else {
								// This was the last section in the deck, so move on to the next deck
								progressToNextDeck()
							}
						}
					}
					.catch(failCurrentCardLoadingState)
			} else {
				// Load the next card where "new" = false and the card is due. Also, sort by the due date ASCENDING.
				user.documentReference
					.collection("decks/\(currentDeck.id)/cards")
					.whereField("new", isEqualTo: false)
					.whereField("due", isLessThanOrEqualTo: Date())
					.order(by: "due")
					.start(afterDocument: continueFromSnapshot && !(current?.isNew ?? true) ? currentCard?.snapshot : nil)
					.limit(to: 1)
					.getDocuments()
					.done { snapshot in
						if let userData = snapshot.documents.first.map(Card.UserData.init) {
							// Found the next card, so update the current card with it
							updateCurrentCard(
								withId: userData.id,
								sectionId: userData.sectionId,
								userData: userData
							)
						} else {
							// There are no more non-new cards in the current deck,
							// so progress to the next deck and try to find non-new cards in there.
							
							// Try to get the next deck
							guard
								let currentDeckIndex = self.user.decks.firstIndex(of: currentDeck),
								let newCurrentDeck = self.user.decks[safe: currentDeckIndex + 1]
							else {
								// This was the last deck, so start from the first deck and review new cards only
								
								// Reset the current deck to the user's first deck
								self.currentDeck = self.user.decks.first
								
								// Reset the current section to the first deck's unsectioned section
								self.currentSection = self.currentDeck?.unsectionedSection
								
								// Start reviewing new cards only
								self.isReviewingNewCards = true
								
								// Call the function again with the new current deck and current section
								self.loadNextCard(
									incrementCurrentIndex: false,
									startLoading: false,
									continueFromSnapshot: false
								)
								
								return
							}
							
							// There was a deck after the current deck, so update the current deck with it
							self.currentDeck = newCurrentDeck
							
							// Call the function again with the new current deck
							self.loadNextCard(
								incrementCurrentIndex: false,
								startLoading: false,
								continueFromSnapshot: false
							)
						}
					}
					.catch(failCurrentCardLoadingState)
			}
		}
	}
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				ZStack(alignment: .top) {
					Group {
						Color.lightGrayBackground
						HomeViewTopGradient(
							addedHeight: geometry.safeAreaInsets.top
						)
					}
					.edgesIgnoringSafeArea(.all)
					VStack {
						ReviewViewTopControls(
							currentIndex: self.currentIndex,
							numberOfTotalCards: self.numberOfTotalCards,
							skipCard: self.skipCard,
							recapView: { self.recapView }
						)
						.padding(.horizontal, 23)
						ReviewViewCardSection(
							deck: self.deck,
							currentDeck: self.currentDeck,
							section: self.section,
							currentSection: self.currentSection,
							current: self.current,
							cardOffset: self.cardOffset,
							isWaitingForRating: self.isWaitingForRating,
							currentSide: self.$currentSide
						)
						.padding(.top, 6)
						.padding(.horizontal, 8)
						ReviewViewFooter(
							current: self.current,
							isWaitingForRating: self.isWaitingForRating,
							rateCurrentCard: self.rateCurrentCard
						)
						.padding(.top, 16)
					}
				}
				.blur(radius: self.isPopUpShowing ? 5 : 0)
				.onTapGesture {
					if
						self.isWaitingForRating ||
						self.current == nil
					{ return }
					self.waitForRating()
				}
				.disabled(self.isPopUpShowing)
				ReviewViewPopUp(data: self.popUpData, offset: self.popUpOffset)
				NavigateTo(
					LazyView { self.recapView },
					when: self.$shouldShowRecap
				)
			}
		}
		.onAppear {
			self.initialXP = self.currentStore.user.xp
			self.loadNumberOfTotalCards()
			self.loadCurrentDeck()
			self.loadNextCard()
		}
	}
}

#if DEBUG
struct ReviewView_Previews: PreviewProvider {
	static var previews: some View {
		ReviewView(
			user: PREVIEW_CURRENT_STORE.user,
			deck: nil,
			section: nil
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

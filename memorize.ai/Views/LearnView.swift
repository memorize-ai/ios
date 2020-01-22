import SwiftUI
import FirebaseFirestore
import LoadingState

struct LearnView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	static let POP_UP_SLIDE_DURATION = 0.25
	static let CARD_SLIDE_DURATION = 0.25
	static let XP_CHANCE = 0.2
	
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
	
	let deck: Deck
	let section: Deck.Section?
	
	@State var numberOfTotalCards = 0
	
	@State var current: Card.LearnData?
	@State var currentIndex = -1
	@State var currentSide = Card.Side.front
	
	@State var currentSectionIndex = 0
	@State var currentSectionCardIndex = -1
	
	@State var isWaitingForRating = false
	
	@State var shouldShowRecap = false
	
	@State var popUpOffset: CGFloat = -SCREEN_SIZE.width
	@State var popUpData: PopUpData?
	
	@State var cardOffset: CGFloat = 0
	
	@State var currentCardLoadingState = LoadingState()
	
	@State var xpGained = 0
	
	@State var cards = [Card.LearnData]()
	@State var initialXP = 0
	
	init(deck: Deck, section: Deck.Section?) {
		self.deck = deck
		self.section = section
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
	
	var recapView: some View {
		LearnRecapView(
			deck: deck,
			section: section,
			xpGained: xpGained,
			initialXP: initialXP,
			totalEasyRatingCount: totalRatingCount(forRating: .easy),
			totalStruggledRatingCount: totalRatingCount(forRating: .struggled),
			totalForgotRatingCount: totalRatingCount(forRating: .forgot),
			frequentlyEasySections: frequentSections(forRating: .easy),
			frequentlyStruggledSections: frequentSections(forRating: .struggled),
			frequentlyForgotSections: frequentSections(forRating: .forgot),
			frequentCardsForRating: frequentCards,
			numberOfReviewedCardsForSection: numberOfReviewedCardsForSection
		)
	}
	
	func loadNumberOfTotalCards() {
		numberOfTotalCards = section?.numberOfCards ?? deck.numberOfUnlockedCards
	}
	
	func loadCurrentSectionIndex() {
		currentSectionIndex = deck.hasUnsectionedCards ? -1 : 0
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
		didIncrementStreak: Bool,
		onCentered: (() -> Void)? = nil,
		completion: (() -> Void)? = nil
	) {
		let badges = [
			didGainXP
				? PopUpBadge(text: "+1 xp", color: Card.PerformanceRating.easy.badgeColor.opacity(0.16))
				: nil,
			current.map { current in
				PopUpBadge(
					text: "\(current.streak)/\(Card.LearnData.NUMBER_OF_CONSECUTIVE_EASY_ATTEMPTS_FOR_MASTERED) streak",
					color: (didIncrementStreak ? Card.PerformanceRating.easy : Card.PerformanceRating.forgot).badgeColor.opacity(0.16)
				)
			}
		].compactMap { $0 }
		
		switch rating {
		case .easy:
			switch true {
			case current?.isMastered:
				showPopUp(emoji: "🎉", message: "Mastered!", badges: badges, onCentered: onCentered, completion: completion)
			case current?.streak ?? 0 > 2:
				showPopUp(emoji: "🎉", message: "On a roll!", badges: badges, onCentered: onCentered, completion: completion)
			default:
				showPopUp(emoji: "🎉", message: "Great!", badges: badges, onCentered: onCentered, completion: completion)
			}
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
	
	func rateCurrentCard(withRating rating: Card.PerformanceRating, user: User) {
		let gainXP = shouldGainXP
		
		if gainXP {
			xpGained++
		}
		
		withAnimation(.easeIn(duration: 0.3)) {
			isWaitingForRating = false
		}
		
		showPopUp(
			forRating: rating,
			didGainXP: gainXP,
			didIncrementStreak: current?.addRating(rating) ?? false,
			onCentered: {
				if self.isAllMastered { return }
				self.loadNextCard()
			},
			completion: {
				if gainXP {
					user.documentReference.updateData([
						"xp": FieldValue.increment(1 as Int64)
					]) as Void
				}
				
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
				
				deck.documentReference
					.collection("cards")
					.whereField("section", isEqualTo: section.id)
					.start(afterDocument: currentCard?.snapshot)
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
					currentSection.contains(card: currentCard),
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
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				ZStack(alignment: .top) {
					Group {
						Color.lightGrayBackground
						HomeViewTopGradient(
							colors: [
								.init(#colorLiteral(red: 0.03529411765, green: 0.6156862745, blue: 0.4117647059, alpha: 1)),
								.init(#colorLiteral(red: 0.7529411765, green: 0.8862745098, blue: 0.2549019608, alpha: 1))
							],
							addedHeight: geometry.safeAreaInsets.top
						)
					}
					.edgesIgnoringSafeArea(.all)
					VStack {
						Group {
							LearnViewTopControls(
								currentIndex: self.currentIndex,
								numberOfTotalCards: self.numberOfTotalCards,
								skipCard: self.skipCard,
								recapView: { self.recapView }
							)
							LearnViewSliders(
								numberOfTotalCards: self.numberOfTotalCards,
								numberOfMasteredCards: self.numberOfMasteredCards,
								numberOfSeenCards: self.numberOfSeenCards,
								numberOfUnseenCards: self.numberOfUnseenCards
							)
						}
						.padding(.horizontal, 23)
						LearnViewCardSection(
							deck: self.deck,
							currentSide: self.$currentSide,
							section: self.section,
							currentSection: self.currentSection,
							cardOffset: self.cardOffset,
							currentCard: self.currentCard,
							isWaitingForRating: self.isWaitingForRating
						)
						.padding(.top, 6)
						.padding(.horizontal, 8)
						LearnViewFooter(
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
				LearnViewPopUp(data: self.popUpData, offset: self.popUpOffset)
				NavigateTo(
					LazyView {
						self.recapView
							.environmentObject(self.currentStore)
							.navigationBarRemoved()
					},
					when: self.$shouldShowRecap
				)
			}
		}
		.onAppear {
			self.initialXP = self.currentStore.user.xp
			self.loadNumberOfTotalCards()
			self.loadCurrentSectionIndex()
			self.loadNextCard()
		}
	}
}

#if DEBUG
struct LearnView_Previews: PreviewProvider {
	static var previews: some View {
		LearnView(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			section: nil
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

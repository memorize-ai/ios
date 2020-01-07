import Foundation
import Combine
import FirebaseFirestore

final class ReviewViewModel: ViewModel {
	let user: User
	let deck: Deck?
	let section: Deck.Section?
	
	let numberOfCards: Int
	
	@Published var currentCard: Card?
	@Published var currentCardSnapshot: DocumentSnapshot?
	@Published var currentCardIndex = -1
	
	@Published var isWaitingForPerformanceRating = false
	
	var isDoneWithSeenCards = false
	
	init(user: User, deck: Deck?, section: Deck.Section?) {
		self.user = user
		self.deck = deck
		self.section = section
		
		if let section = section {
			numberOfCards = section.numberOfDueCards ?? 0
		} else if let deck = deck {
			numberOfCards = deck.userData?.numberOfDueCards ?? 0
		} else {
			numberOfCards = user.numberOfDueCards
		}
		
		loadNextCard()
	}
	
	func loadNextCard() {
		currentCardIndex++
		
//		if let section = section {
//			firestore
//				.collection("decks/\(section.parent.id)/cards")
//				.whereField("section", isEqualTo: section.id)
//				.start(afterDocument: )
//		} else if let deck = deck {
//			var query = user.documentReference
//				.collection("decks/\(deck.id)/cards")
//				.whereField("due", isLessThanOrEqualTo: Date())
//				.order(by: "due")
//
//			if let currentCardSnapshot = currentCardSnapshot {
//				query = query.start(afterDocument: currentCardSnapshot)
//			}
//
//			query
//				.limit(to: 1)
//				.getDocuments()
//				.done { snapshot in
//					if let document = snapshot.documents.first {
//						self.currentCard = .init(snapshot: document)
//					} else {
//						self.isDoneWithSeenCards = true
//						self.loadNextUnseenCard(
//							incrementCurrentCardIndex: false
//						)
//					}
//				}
//				.catch { error in
//					print(error) // TODO: Handle error with alert
//				}
//		} else {
//
//		}
	}
	
	func loadNextUnseenCard(incrementCurrentCardIndex: Bool = true) {
		if incrementCurrentCardIndex {
			currentCardIndex++
		}
		
//		if let section = section {
//
//		} else if let deck = deck {
//			deck.documentReference
//				.collection("cards")
//				.whereField(FieldPath.documentID(), isEqualTo: )
//		} else {
//
//		}
	}
}

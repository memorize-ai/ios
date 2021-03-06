import Combine
import FirebaseFirestore
import PromiseKit
import LoadingState

extension Deck {
	final class Section: ObservableObject, Identifiable, Equatable, Hashable {
		let id: String
		let parent: Deck
		
		@Published var name: String
		@Published var index: Int
		@Published var numberOfCards: Int
		
		@Published var cards: [Card]
		@Published var cardsLoadingState = LoadingState()
		
		@Published var renameLoadingState = LoadingState()
		@Published var unlockLoadingState = LoadingState()
		@Published var deleteLoadingState = LoadingState()
		
		var snapshotListener: ListenerRegistration?
		
		init(
			id: String?,
			parent: Deck,
			name: String,
			index: Int,
			numberOfCards: Int,
			cards: [Card] = [],
			snapshotListener: ListenerRegistration? = nil
		) {
			self.id = id ?? ""
			self.parent = parent
			self.name = name
			self.index = index
			self.numberOfCards = numberOfCards
			self.cards = cards
			self.snapshotListener = snapshotListener
		}
		
		convenience init(
			parent: Deck,
			snapshot: DocumentSnapshot,
			snapshotListener: ListenerRegistration? = nil
		) {
			self.init(
				id: snapshot.documentID,
				parent: parent,
				name: snapshot.get("name") as? String ?? "Unknown",
				index: snapshot.get("index") as? Int ?? 0,
				numberOfCards: snapshot.get("cardCount") as? Int ?? 0,
				snapshotListener: snapshotListener
			)
		}
		
		var documentReference: DocumentReference {
			parent.documentReference.collection("sections").document(id)
		}
		
		var isUnsectioned: Bool {
			id.isEmpty
		}
		
		var numberOfDueCards: Int? {
			parent.userData?.numberOfDueCardsForSection(withId: id)
		}
		
		var isDue: Bool {
			guard let numberOfDueCards = numberOfDueCards else { return false }
			return numberOfDueCards > 0
		}
		
		var unlockUrl: URL? {
			URL(string: "\(WEB_URL)/d/\(parent.slugId)/\(parent.slug)/u/\(id)")
		}
		
		var unlockLink: String? {
			unlockUrl?.absoluteString
		}
		
		var isUnlocked: Bool {
			parent.userData?.isSectionUnlocked(withId: id) ?? false
		}
		
		@discardableResult
		func addObserver() -> Self {
			guard snapshotListener == nil else { return self }
			onBackgroundThread {
				self.snapshotListener = self.documentReference.addSnapshotListener { snapshot, error in
					guard error == nil, let snapshot = snapshot else { return }
					onMainThread {
						self.updateFromSnapshot(snapshot)
					}
				}
			}
			return self
		}
		
		@discardableResult
		func loadCards(withUserDataForUser user: User? = nil) -> Self {
			guard cardsLoadingState.isNone else { return self }
			cardsLoadingState.startLoading()
			onBackgroundThread {
				self.parent
					.documentReference
					.collection("cards")
					.whereField("section", isEqualTo: self.id)
					.addSnapshotListener { snapshot, error in
						guard
							error == nil,
							let documentChanges = snapshot?.documentChanges
						else {
							onMainThread {
								self.cardsLoadingState.fail(error: error ?? UNKNOWN_ERROR)
							}
							return
						}
						for change in documentChanges {
							let document = change.document
							let cardId = document.documentID
							switch change.type {
							case .added:
								let card = Card(snapshot: document, parent: self.parent)
								onMainThread {
									self.cards.append(user.map { user in
										card.loadUserData(forUser: user, deck: self.parent)
									} ?? card)
								}
							case .modified:
								onMainThread {
									self.cards.first { $0.id == cardId }?
										.updateFromSnapshot(document)
								}
							case .removed:
								onMainThread {
									self.cards.removeAll { $0.id == cardId }
								}
							}
						}
						onMainThread {
							self.cardsLoadingState.succeed()
						}
					}
			}
			return self
		}
		
		@discardableResult
		func updateFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
			name = snapshot.get("name") as? String ?? name
			index = snapshot.get("index") as? Int ?? index
			numberOfCards = snapshot.get("cardCount") as? Int ?? 0
			return self
		}
		
		func contains(card: Card) -> Bool {
			card.sectionId == id.nilIfEmpty
		}
		
		func contains(card: Card.Draft) -> Bool {
			card.sectionId == id.nilIfEmpty
		}
		
		@discardableResult
		func showRenameAlert(title: String = "Rename section", message: String? = nil) -> Self {
			showAlert(title: title, message: message) { alert in
				alert.addTextField { textField in
					textField.placeholder = "Name"
					textField.text = self.name
				}
				alert.addAction(.init(title: "Cancel", style: .cancel))
				alert.addAction(.init(title: "Rename", style: .default) { _ in
					guard let name = alert.textFields?.first?.text else { return }
					self.renameLoadingState.startLoading()
					onBackgroundThread {
						self.documentReference.updateData([
							"name": name
						]).done {
							onMainThread {
								self.renameLoadingState.succeed()
							}
						}.catch { error in
							onMainThread {
								self.renameLoadingState.fail(error: error)
							}
						}
					}
				})
			}
			return self
		}
		
		@discardableResult
		func showUnlockAlert(
			forUser user: User,
			message: String? = "Are you sure?",
			completion: (() -> Void)? = nil
		) -> Self {
			showAlert(title: "Unlock \(name)", message: message) { alert in
				alert.addAction(.init(title: "Cancel", style: .cancel))
				alert.addAction(.init(title: "Unlock", style: .default) { _ in
					self.unlock(forUser: user)
					completion?()
				})
			}
			return self
		}
		
		@discardableResult
		func unlock(forUser user: User) -> Self {
			let incrementByNumberOfCards = FieldValue.increment(Int64(numberOfCards))
			
			unlockLoadingState.startLoading()
			onBackgroundThread {
				user.documentReference.collection("decks").document(self.parent.id).updateData([
					"dueCardCount": incrementByNumberOfCards,
					"unlockedCardCount": incrementByNumberOfCards,
					"sections.\(self.id)": self.numberOfCards
				]).done {
					onMainThread {
						self.unlockLoadingState.succeed()
					}
				}.catch { error in
					onMainThread {
						self.unlockLoadingState.fail(error: error)
					}
				}
			}
			
			return self
		}
		
		@discardableResult
		func showDeleteAlert(
			message: String? = "Are you sure? All of the cards in this section will be permanently deleted. This action cannot be undone.", // swiftlint:disable:this line_length
			completion: (() -> Void)? = nil
		) -> Self {
			showAlert(title: "Delete \(name)", message: message) { alert in
				alert.addAction(.init(title: "Cancel", style: .cancel))
				alert.addAction(.init(title: "Delete", style: .destructive) { _ in
					self.delete()
					completion?()
				})
			}
			return self
		}
		
		@discardableResult
		func delete() -> Self {
			deleteLoadingState.startLoading()
			onBackgroundThread {
				self.documentReference.delete().done {
					onMainThread {
						self.deleteLoadingState.succeed()
					}
				}.catch { error in
					onMainThread {
						self.deleteLoadingState.fail(error: error)
					}
				}
			}
			return self
		}
		
		static func == (lhs: Section, rhs: Section) -> Bool {
			lhs.id == rhs.id && lhs.parent == rhs.parent
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
			hasher.combine(parent)
		}
	}
}

import UIKit
import CoreData
import FirebaseAuth

class UserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var loadingImage: UIImageView!
	@IBOutlet weak var offlineView: UIView!
	@IBOutlet weak var retryButton: UIButton!
	@IBOutlet weak var actionsCollectionView: UICollectionView!
	@IBOutlet weak var cardsTableView: UITableView!
	@IBOutlet weak var reviewButton: UIButton!
	@IBOutlet weak var cardsLabel: UILabel!
	
	class Action {
		let image: UIImage?
		let name: String
		let action: Selector?
		var enabled: Bool
		
		init(image: UIImage?, name: String, action: Selector?) {
			self.image = image
			self.name = name
			self.action = action
			self.enabled = false
		}
	}
	
	let actions = [Action(image: #imageLiteral(resourceName: "Decks"), name: "DECKS", action: #selector(showDecks)), Action(image: #imageLiteral(resourceName: "Cards"), name: "CARDS", action: #selector(showCards)), Action(image: #imageLiteral(resourceName: "Create"), name: "CREATE DECK", action: #selector(createDeck)), Action(image: #imageLiteral(resourceName: "Search"), name: "SEARCH DECKS", action: #selector(searchDeck))]
	var cards = [(image: UIImage, card: Card)]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if startup {
			navigationController?.setNavigationBarHidden(true, animated: false)
			loadingView.isHidden = false
			loadingImage.isHidden = false
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
				let managedContext = appDelegate.persistentContainer.viewContext
				let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Login")
				do {
					let login = try managedContext.fetch(fetchRequest)
					if login.count == 1 {
						let localEmail = login[0].value(forKey: "email") as? String
						loadProfileBarButtonItem(login[0].value(forKey: "image") as? Data)
						Auth.auth().signIn(withEmail: localEmail!, password: login[0].value(forKey: "password") as? String ?? "Error") { user, error in
							if error == nil, let uid = user?.user.uid {
								id = uid
								pushToken()
								firestore.document("users/\(uid)").addSnapshotListener { snapshot, error in
									guard error == nil, let snapshot = snapshot else { return }
									name = snapshot.get("name") as? String ?? "Error"
									email = localEmail
									slug = snapshot.get("slug") as? String ?? "error"
									self.loadingImage.isHidden = true
									self.loadingView.isHidden = true
									self.navigationController?.setNavigationBarHidden(false, animated: false)
									self.reloadProfileBarButtonItem()
									startup = false
									callChangeHandler(.profileModified)
								}
								self.loadDecks()
							} else if let error = error {
								switch error.localizedDescription {
								case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
									self.loadingImage.isHidden = true
									self.offlineView.isHidden = false
									self.retryButton.isHidden = false
								default:
									self.signIn()
								}
							}
						}
					} else {
						signIn()
					}
				} catch {}
			}
			Card.poll()
		} else if shouldLoadDecks {
			loadDecks()
			Card.poll()
			navigationController?.setNavigationBarHidden(false, animated: true)
			shouldLoadDecks = false
		}
		navigationItem.setHidesBackButton(true, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let flowLayout = UICollectionViewFlowLayout()
		let width = view.bounds.width / 2 - 45
		flowLayout.itemSize = CGSize(width: width, height: width / 1.75)
		actionsCollectionView.collectionViewLayout = flowLayout
		reviewButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		updateChangeHandler { change in
			if change == .deckModified || change == .deckRemoved || change == .cardModified || change == .cardRemoved || change == .cardDue {
				self.loadCards()
				self.actionsCollectionView.reloadData()
				self.cardsTableView.reloadData()
				self.reloadReview()
			}
		}
		loadCards()
		actionsCollectionView.reloadData()
		cardsTableView.reloadData()
	}
	
	@IBAction func retry() {
		offlineView.isHidden = true
		retryButton.isHidden = true
		viewDidLoad()
	}
	
	func loadCards() {
		cards = Card.sortDue(Deck.allDue()).map { return (image: #imageLiteral(resourceName: "Gray Circle"), card: $0) }
		cards.append(contentsOf: Card.all().filter { return $0.last != nil }.sorted { return $0.last!.date.timeIntervalSinceNow < $1.last!.date.timeIntervalSinceNow }.map { return (image: UIImage(named: "Quality \($0.last!.rating)")!, card: $0) })
	}
	
	func signIn() {
		performSegue(withIdentifier: "signIn", sender: self)
	}
	
	func leftBarButtonItem(image: UIImage) {
		let editProfileButton = UIButton(type: .custom)
		editProfileButton.setImage(image, for: .normal)
		editProfileButton.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
		editProfileButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
		editProfileButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
		editProfileButton.layer.cornerRadius = 16
		editProfileButton.layer.masksToBounds = true
		let editProfileBarButtonItem = UIBarButtonItem()
		editProfileBarButtonItem.customView = editProfileButton
		let titleLabel = UILabel()
		titleLabel.text = "  memorize.ai"
		titleLabel.font = UIFont(name: "Nunito-ExtraBold", size: 20)
		titleLabel.textColor = .white
		titleLabel.sizeToFit()
		let titleBarButtonItem = UIBarButtonItem(customView: titleLabel)
		navigationItem.setLeftBarButtonItems([editProfileBarButtonItem, titleBarButtonItem], animated: false)
	}
	
	func loadProfileBarButtonItem(_ data: Data?) {
		let image = UIImage(data: data ?? #imageLiteral(resourceName: "Person").pngData()!) ?? #imageLiteral(resourceName: "Person")
		leftBarButtonItem(image: image)
		profilePicture = image
	}
	
	func reloadProfileBarButtonItem() {
		storage.child("users/\(id!)").getData(maxSize: fileLimit) { data, error in
			guard error == nil, let data = data, let image = UIImage(data: data) else { return }
			self.leftBarButtonItem(image: image)
			profilePicture = image
			saveImage(image)
			callChangeHandler(.profilePicture)
		}
	}
	
	func reloadReview() {
		let dueCards = Deck.allDue()
		if reviewButton.isHidden && !dueCards.isEmpty {
			cardsLabel.text = "1 card due"
			reviewButton.transform = CGAffineTransform(translationX: 0, y: 79)
			cardsLabel.transform = CGAffineTransform(translationX: 0, y: 25)
			reviewButton.isHidden = false
			cardsLabel.isHidden = false
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
				self.reviewButton.transform = .identity
				self.cardsLabel.transform = .identity
			}, completion: nil)
		} else if !reviewButton.isHidden && dueCards.isEmpty {
			cardsLabel.text = "0 cards due"
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
				self.reviewButton.transform = CGAffineTransform(translationX: 0, y: 79)
				self.cardsLabel.transform = CGAffineTransform(translationX: 0, y: 25)
			}) { finished in
				if finished {
					self.reviewButton.isHidden = true
					self.cardsLabel.isHidden = true
				}
			}
		} else {
			cardsLabel.text = "\(dueCards.count) card\(dueCards.count == 1 ? "" : "s") due"
		}
	}
	
	@objc func editProfile() {
		performSegue(withIdentifier: "editProfile", sender: self)
	}
	
	@objc func showDecks() {
		performSegue(withIdentifier: "decks", sender: self)
	}
	
	@objc func showCards() {
		performSegue(withIdentifier: "cards", sender: self)
	}
	
	@objc func createDeck() {
		performSegue(withIdentifier: "createDeck", sender: self)
	}
	
	@objc func searchDeck() {
		performSegue(withIdentifier: "searchDeck", sender: self)
	}
	
	@IBAction func review() {
		performSegue(withIdentifier: "review", sender: self)
	}
	
	func loadDecks() {
		firestore.collection("users/\(id!)/decks").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot?.documentChanges else { return }
			snapshot.forEach {
				let deck = $0.document
				let deckId = deck.documentID
				switch $0.type {
				case .added:
					firestore.document("decks/\(deckId)").addSnapshotListener { deckSnapshot, deckError in
						guard deckError == nil, let deckSnapshot = deckSnapshot else { return }
						if let deckIndex = Deck.id(deckSnapshot.documentID) {
							let localDeck = decks[deckIndex]
							localDeck.name = deckSnapshot.get("name") as? String ?? "Error"
							localDeck.description = deckSnapshot.get("description") as? String ?? "Error"
							localDeck.isPublic = deckSnapshot.get("public") as? Bool ?? true
							localDeck.count = deckSnapshot.get("count") as? Int ?? 0
							localDeck.mastered = deck.get("mastered") as? Int ?? 0
							localDeck.creator = deckSnapshot.get("creator") as? String ?? "Error"
							localDeck.owner = deckSnapshot.get("owner") as? String ?? "Error"
						} else {
							decks.append(Deck(id: deckId, image: nil, name: deckSnapshot.get("name") as? String ?? "Error", description: deckSnapshot.get("description") as? String ?? "Error", isPublic: deckSnapshot.get("public") as? Bool ?? true, count: deckSnapshot.get("count") as? Int ?? 0, mastered: deck.get("mastered") as? Int ?? 0, creator: deckSnapshot.get("creator") as? String ?? "Error", owner: deckSnapshot.get("owner") as? String ?? "Error", permissions: [], cards: []))
						}
						callChangeHandler(.deckModified)
						firestore.collection("decks/\(deckId)/cards").addSnapshotListener { snapshot, error in
							guard error == nil, let snapshot = snapshot?.documentChanges else { return }
							snapshot.forEach {
								let card = $0.document
								let cardId = card.documentID
								guard let localDeckIndex = Deck.id(deckId) else { return }
								let localDeck = decks[localDeckIndex]
								switch $0.type {
								case .added:
									firestore.document("users/\(id!)/decks/\(deckId)/cards/\(cardId)").addSnapshotListener { cardSnapshot, cardError in
										guard cardError == nil, let cardSnapshot = cardSnapshot else { return }
										let last = cardSnapshot.get("last") as? [String : Any]
										let cardLast = last == nil ? nil : Card.Last(id: last?["id"] as? String ?? "Error", date: last?["date"] as? Date ?? Date(), rating: last?["rating"] as? Int ?? 0, elapsed: last?["elapsed"] as? Int ?? 0)
										if let cardIndex = localDeck.card(id: cardId) {
											let localCard = localDeck.cards[cardIndex]
											localCard.count = cardSnapshot.get("count") as? Int ?? 0
											localCard.correct = cardSnapshot.get("correct") as? Int ?? 0
											localCard.streak = cardSnapshot.get("streak") as? Int ?? 0
											localCard.mastered = cardSnapshot.get("mastered") as? Bool ?? false
											localCard.last = cardLast
											localCard.next = cardSnapshot.get("next") as? Date ?? Date()
										} else {
											localDeck.cards.append(Card(id: cardId, front: card.get("front") as? String ?? "Error", back: card.get("back") as? String ?? "Error", count: cardSnapshot.get("count") as? Int ?? 0, correct: cardSnapshot.get("correct") as? Int ?? 0, streak: cardSnapshot.get("streak") as? Int ?? 0, mastered: cardSnapshot.get("mastered") as? Bool ?? false, last: cardLast, next: cardSnapshot.get("next") as? Date ?? Date(), history: [], deck: deckId))
										}
										self.reloadReview()
										callChangeHandler(.cardModified)
									}
								case .modified:
									let modifiedCard = localDeck.cards[localDeck.card(id: cardId)!]
									if let front = card.get("front") as? String, let back = card.get("back") as? String {
										modifiedCard.front = front
										modifiedCard.back = back
									}
									self.reloadReview()
									callChangeHandler(.cardModified)
								case .removed:
									localDeck.cards = localDeck.cards.filter { return $0.id != cardId }
									self.reloadReview()
									callChangeHandler(.cardRemoved)
								@unknown default:
									return
								}
							}
						}
					}
				case .modified:
					if let mastered = deck.get("mastered") as? Int {
						decks[Deck.id(deckId)!].mastered = mastered
					}
					callChangeHandler(.deckModified)
				case .removed:
					decks = decks.filter { return $0.id != deckId }
					callChangeHandler(.deckRemoved)
				@unknown default:
					return
				}
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return actions.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UserActionCollectionViewCell
		let element = actions[indexPath.item]
		cell.imageView.image = element.image
		cell.label.text = element.name
		element.enabled = !((element.name == "DECKS" && decks.isEmpty) || (element.name == "CARDS" && Card.all().isEmpty))
		cell.enable(element.enabled)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let element = actions[indexPath.item]
		guard element.enabled, let action = element.action else { return }
		performSelector(onMainThread: action, with: nil, waitUntilDone: false)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cards.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = cards[indexPath.row]
		cell.imageView?.image = element.image
		cell.textLabel?.text = element.card.front
		return cell
	}
}

class UserActionCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var barView: UIView!
	
	func enable(_ enabled: Bool) {
		let color = enabled ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		label.textColor = color
		barView.backgroundColor = color
	}
}

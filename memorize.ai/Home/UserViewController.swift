import UIKit
import CoreData
import FirebaseAuth

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var offlineView: UIView!
	@IBOutlet weak var retryButton: UIButton!
	@IBOutlet weak var actionsTableView: UITableView!
	@IBOutlet weak var reviewButton: UIButton!
	@IBOutlet weak var cardsLabel: UILabel!
	
	struct Action {
		let image: UIImage?
		let name: String
		let action: Selector?
	}
	
	let actions = [Action(image: #imageLiteral(resourceName: "Decks"), name: "Decks", action: #selector(showDecks)), Action(image: #imageLiteral(resourceName: "Cards"), name: "Cards", action: #selector(showCards)), Action(image: #imageLiteral(resourceName: "Create"), name: "Create a deck", action: #selector(createDeck)), Action(image: #imageLiteral(resourceName: "Search"), name: "Search for a deck", action: #selector(searchDeck))]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if startup {
			loadingView.isHidden = false
			activityIndicator.startAnimating()
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
				let managedContext = appDelegate.persistentContainer.viewContext
				let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Login")
				do {
					let login = try managedContext.fetch(fetchRequest)
					if login.count == 1 {
						let localEmail = login[0].value(forKey: "email") as? String
						Auth.auth().signIn(withEmail: localEmail!, password: login[0].value(forKey: "password") as? String ?? "Error") { user, error in
							if error == nil {
								id = user?.user.uid
								firestore.collection("users").document(id!).addSnapshotListener { snapshot, error in
									guard error == nil, let snapshot = snapshot else { return }
									name = snapshot.get("name") as? String ?? "Error"
									self.navigationController?.setNavigationBarHidden(false, animated: true)
									self.navigationItem.title = name
									email = localEmail
									slug = snapshot.get("slug") as? String ?? "error"
									self.activityIndicator.stopAnimating()
									self.loadingView.isHidden = true
									self.createProfileBarButtonItem()
									startup = false
									callChangeHandler(.profileModified)
								}
								self.loadDecks()
							} else if let error = error {
								switch error.localizedDescription {
								case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
									self.activityIndicator.stopAnimating()
									self.offlineView.isHidden = false
									self.retryButton.isHidden = false
									self.navigationController?.setNavigationBarHidden(true, animated: true)
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
		} else {
			createProfileBarButtonItem()
			navigationItem.title = name
			if shouldLoadDecks {
				loadDecks()
				shouldLoadDecks = false
			}
		}
		navigationItem.setHidesBackButton(true, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .deckModified || change == .deckRemoved || change == .cardModified || change == .cardRemoved {
				self.actionsTableView.reloadData()
			}
		}
		actionsTableView.reloadData()
	}
	
	@IBAction func retry() {
		offlineView.isHidden = true
		retryButton.isHidden = true
		viewDidLoad()
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
		let editProfileBarButtonItem = UIBarButtonItem()
		editProfileBarButtonItem.customView = editProfileButton
		navigationItem.setLeftBarButton(editProfileBarButtonItem, animated: false)
	}
	
	func createProfileBarButtonItem() {
		leftBarButtonItem(image: #imageLiteral(resourceName: "Person"))
		storage.child("users/\(id!)").getData(maxSize: fileLimit) { data, error in
			guard error == nil, let data = data else { return }
			profilePicture = UIImage(data: data) ?? #imageLiteral(resourceName: "Person")
			callChangeHandler(.profilePicture)
			self.leftBarButtonItem(image: profilePicture!)
		}
	}
	
	func reloadReview() {
		let dueCards = Deck.allDue()
		if reviewButton.isHidden {
			cardsLabel.text = "1 card due"
			reviewButton.transform = CGAffineTransform(translationX: 0, y: 79)
			cardsLabel.transform = CGAffineTransform(translationX: 0, y: 25)
			reviewButton.isHidden = false
			cardsLabel.isHidden = false
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
				self.reviewButton.transform = .identity
				self.cardsLabel.transform = .identity
			}, completion: nil)
		} else if dueCards.isEmpty {
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
		firestore.collection("users").document(id!).collection("decks").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot?.documentChanges else { return }
			snapshot.forEach {
				let deck = $0.document
				let deckId = deck.documentID
				switch $0.type {
				case .added:
					firestore.collection("decks").document(deckId).addSnapshotListener { deckSnapshot, deckError in
						guard deckError == nil, let deckSnapshot = deckSnapshot else { return }
						decks.append(Deck(id: deckId, image: nil, name: deckSnapshot.get("name") as? String ?? "Error", description: deckSnapshot.get("description") as? String ?? "Error", isPublic: deckSnapshot.get("public") as? Bool ?? true, count: deckSnapshot.get("count") as? Int ?? 0, mastered: deck.get("mastered") as? Int ?? 0, creator: deckSnapshot.get("creator") as? String ?? "Error", owner: deckSnapshot.get("owner") as? String ?? "Error", permissions: [], cards: []))
						callChangeHandler(.deckModified)
						firestore.collection("decks").document(deckId).collection("cards").addSnapshotListener { snapshot, error in
							guard error == nil, let snapshot = snapshot?.documentChanges else { return }
							snapshot.forEach {
								let card = $0.document
								let cardId = card.documentID
								guard let localDeckIndex = Deck.id(deckId) else { return }
								let localDeck = decks[localDeckIndex]
								switch $0.type {
								case .added:
									firestore.collection("users").document(id!).collection("decks").document(deckId).collection("cards").document(cardId).addSnapshotListener { cardSnapshot, cardError in
										guard cardError == nil, let cardSnapshot = cardSnapshot else { return }
										if let cardIndex = localDeck.card(id: cardId) {
											let localCard = localDeck.cards[cardIndex]
											localCard.count = cardSnapshot.get("count") as? Int ?? 0
											localCard.correct = cardSnapshot.get("correct") as? Int ?? 0
											localCard.streak = cardSnapshot.get("streak") as? Int ?? 0
											localCard.mastered = cardSnapshot.get("mastered") as? Bool ?? false
											localCard.last = cardSnapshot.get("last") as? String ?? "Error"
											localCard.next = cardSnapshot.get("next") as? Date ?? Date()
										} else {
											localDeck.cards.append(Card(id: cardId, front: card.get("front") as? String ?? "Error", back: card.get("back") as? String ?? "Error", count: cardSnapshot.get("count") as? Int ?? 0, correct: cardSnapshot.get("correct") as? Int ?? 0, streak: cardSnapshot.get("streak") as? Int ?? 0, mastered: cardSnapshot.get("mastered") as? Bool ?? false, last: cardSnapshot.get("last") as? String ?? "Error", next: cardSnapshot.get("next") as? Date ?? Date(), history: [], deck: deckId))
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
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return actions.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = actions[indexPath.section]
		cell.imageView?.image = element.image
		cell.textLabel?.text = element.name
		switch element.name {
		case "Decks":
			let decksCount = decks.count
			cell.detailTextLabel?.text = "\(decksCount) deck\(decksCount == 1 ? "" : "s")"
		case "Cards":
			let cardsCount = decks.reduce(0) { result, deck in result + deck.cards.count }
			cell.detailTextLabel?.text = "\(cardsCount) card\(cardsCount == 1 ? "" : "s")"
		default:
			cell.detailTextLabel?.text = nil
		}
		cell.accessoryView?.isHidden = element.action == nil
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let action = actions[indexPath.section].action else { return }
		performSelector(onMainThread: action, with: nil, waitUntilDone: false)
	}
}

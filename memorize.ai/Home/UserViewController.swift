import UIKit
import CoreData
import Firebase
import WebKit

class UserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var loadingImage: UIImageView!
	@IBOutlet weak var offlineView: UIView!
	@IBOutlet weak var retryButton: UIButton!
	@IBOutlet weak var helloLabel: UILabel!
	@IBOutlet weak var decksView: UIView!
	@IBOutlet weak var decksLabel: UILabel!
	@IBOutlet weak var decksBarView: UIView!
	@IBOutlet weak var cardsView: UIView!
	@IBOutlet weak var cardsLabel: UILabel!
	@IBOutlet weak var cardsBarView: UIView!
	@IBOutlet weak var createView: UIView!
	@IBOutlet weak var createLabel: UILabel!
	@IBOutlet weak var createBarView: UIView!
	@IBOutlet weak var marketplaceView: UIView!
	@IBOutlet weak var marketplaceLabel: UILabel!
	@IBOutlet weak var marketplaceBarView: UIView!
	@IBOutlet weak var cardsCollectionView: UICollectionView!
	@IBOutlet weak var cardsCollectionViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var reviewButton: UIButton!
	@IBOutlet weak var dueCardsLabel: UILabel!
	
	var enabled = [false, false, true, true]
	var cards = [(image: UIImage, card: Card)]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if startup {
			navigationController?.setNavigationBarHidden(true, animated: false)
			loadingView.isHidden = false
			loadingImage.isHidden = false
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
				let managedContext = appDelegate.persistentContainer.viewContext
				let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
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
									self.createHelloLabel()
									email = localEmail
									slug = snapshot.get("slug") as? String ?? "error"
									self.loadingImage.isHidden = true
									self.loadingView.isHidden = true
									self.navigationController?.setNavigationBarHidden(false, animated: false)
									self.reloadProfileBarButtonItem()
									startup = false
									ChangeHandler.call(.profileModified)
								}
								self.updateLastOnline()
								self.loadSettings()
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
		}
		navigationItem.setHidesBackButton(true, animated: true)
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.itemSize = CGSize(width: view.bounds.width - 80, height: 40)
		flowLayout.minimumLineSpacing = 8
		cardsCollectionView.collectionViewLayout = flowLayout
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		reviewButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		ChangeHandler.update { change in
			if change == .deckModified || change == .deckRemoved || change == .cardModified || change == .cardRemoved || change == .cardDue {
				self.loadCards()
				self.reloadActions()
				self.reloadReview()
			}
		}
		Setting.updateHandler { setting in
			let enabled = setting.value as? Bool ?? false
			switch setting.type {
			case .darkMode:
				let backgroundColor = enabled ? .darkGray : #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
				self.view.backgroundColor = backgroundColor
				self.cardsCollectionView.backgroundColor = backgroundColor
			default:
				break
			}
		}
		reloadReview()
		loadCards()
		createHelloLabel()
		reloadActions()
		loadProfileBarButtonItem(nil)
		cardsCollectionView.reloadData()
		if shouldLoadDecks {
			updateLastOnline()
			reloadProfileBarButtonItem()
			loadDecks()
			Card.poll()
			createHelloLabel()
			navigationController?.setNavigationBarHidden(false, animated: true)
			navigationItem.setHidesBackButton(true, animated: true)
			shouldLoadDecks = false
		}
	}
	
	@IBAction func retry() {
		offlineView.isHidden = true
		retryButton.isHidden = true
		viewDidLoad()
	}
	
	func createHelloLabel() {
		guard let name = name else { return }
		helloLabel.text = "Hello, \(name)"
	}
	
	func updateLastOnline() {
		guard Auth.auth().currentUser != nil else { return }
		functions.httpsCallable("updateLastOnline").call(nil) { _, _ in }
	}
	
	func loadSettings() {
		guard let id = id else { return }
		firestore.collection("settings").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot?.documentChanges else { return }
			snapshot.forEach {
				let setting = $0.document
				let settingId = setting.documentID
				switch $0.type {
				case .added:
					firestore.document("users/\(id)/settings/\(settingId)").addSnapshotListener { settingSnapshot, settingError in
						guard settingError == nil, let settingSnapshot = settingSnapshot, let value = settingSnapshot.exists ? settingSnapshot.get("value") : setting.get("default") else { return }
						let newSetting = Setting(id: settingId, section: setting.get("section") as? String ?? "", slug: setting.get("slug") as? String ?? "", title: setting.get("title") as? String ?? "Error", description: setting.get("description") as? String ?? "", value: value, order: setting.get("order") as? Int ?? 0)
						if let localSettingIndex = Setting.id(settingId) {
							settings[localSettingIndex] = newSetting
							ChangeHandler.call(.settingValueModified)
						} else {
							settings.append(newSetting)
							ChangeHandler.call(.settingAdded)
						}
						Setting.loadSectionedSettings()
						Setting.callHandler(newSetting)
					}
				case .modified:
					guard let localSettingIndex = Setting.id(settingId) else { return }
					let localSetting = settings[localSettingIndex]
					localSetting.title = setting.get("title") as? String ?? "Error"
					localSetting.description = setting.get("description") as? String ?? ""
					localSetting.order = setting.get("order") as? Int ?? 0
					Setting.loadSectionedSettings()
					Setting.callHandler(localSetting)
					ChangeHandler.call(.settingModified)
				case .removed:
					settings = settings.filter { return $0.id != settingId }
					Setting.loadSectionedSettings()
					ChangeHandler.call(.settingRemoved)
				@unknown default:
					break
				}
			}
		}
	}
	
	func loadCards() {
		let count = cards.count
		cards = Card.sortDue(Deck.allDue()).map { return (image: #imageLiteral(resourceName: "Due"), card: $0) }
		cards.append(contentsOf: Card.all().filter { return $0.last != nil }.sorted { return $0.last!.date.timeIntervalSinceNow < $1.last!.date.timeIntervalSinceNow }.map { return (image: Rating.image($0.last!.rating), card: $0) })
		if count != cards.count {
			cardsCollectionView.reloadData()
		}
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
		let image = (data == nil ? profilePicture : UIImage(data: data!)) ?? #imageLiteral(resourceName: "Person")
		leftBarButtonItem(image: image)
		profilePicture = image
	}
	
	func reloadProfileBarButtonItem() {
		storage.child("users/\(id!)").getData(maxSize: fileLimit) { data, error in
			guard error == nil, let data = data, let image = UIImage(data: data) else { return }
			self.leftBarButtonItem(image: image)
			profilePicture = image
			saveImage(data)
			ChangeHandler.call(.profilePicture)
		}
	}
	
	func reloadReview() {
		let dueCards = Deck.allDue()
		if reviewButton.isHidden && !dueCards.isEmpty {
			dueCardsLabel.text = "1 card due"
			reviewButton.transform = CGAffineTransform(translationX: 0, y: 79)
			dueCardsLabel.transform = CGAffineTransform(translationX: 0, y: 25)
			reviewButton.isHidden = false
			dueCardsLabel.isHidden = false
			cardsCollectionViewBottomConstraint.constant = 20
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
				self.reviewButton.transform = .identity
				self.dueCardsLabel.transform = .identity
			}, completion: nil)
		} else if !reviewButton.isHidden && dueCards.isEmpty {
			dueCardsLabel.text = "0 cards due"
			cardsCollectionViewBottomConstraint.constant = -60
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
				self.view.layoutIfNeeded()
				self.reviewButton.transform = CGAffineTransform(translationX: 0, y: 79)
				self.dueCardsLabel.transform = CGAffineTransform(translationX: 0, y: 25)
			}) {
				guard $0 else { return }
				self.reviewButton.isHidden = true
				self.dueCardsLabel.isHidden = true
			}
		} else {
			dueCardsLabel.text = "\(dueCards.count) card\(dueCards.count == 1 ? "" : "s") due"
		}
	}
	
	@objc func editProfile() {
		performSegue(withIdentifier: "editProfile", sender: self)
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
						ChangeHandler.call(.deckModified)
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
										ChangeHandler.call(.cardModified)
									}
								case .modified:
									let modifiedCard = localDeck.cards[localDeck.card(id: cardId)!]
									if let front = card.get("front") as? String, let back = card.get("back") as? String {
										modifiedCard.front = front
										modifiedCard.back = back
									}
									self.reloadReview()
									ChangeHandler.call(.cardModified)
								case .removed:
									localDeck.cards = localDeck.cards.filter { return $0.id != cardId }
									self.reloadReview()
									ChangeHandler.call(.cardRemoved)
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
					ChangeHandler.call(.deckModified)
				case .removed:
					decks = decks.filter { return $0.id != deckId }
					ChangeHandler.call(.deckRemoved)
				@unknown default:
					return
				}
			}
		}
	}
	
	func toggle(_ label: UILabel, _ barView: UIView, enabled: Bool) {
		let color = enabled ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		label.textColor = color
		barView.backgroundColor = color
	}
	
	func reloadActions() {
		let actions = [
			(view: decksView, label: decksLabel, barView: decksBarView),
			(view: cardsView, label: cardsLabel, barView: cardsBarView),
			(view: createView, label: createLabel, barView: createBarView),
			(view: marketplaceView, label: marketplaceLabel, barView: marketplaceBarView)
		]
		for i in 0...3 {
			let action = actions[i]
			action.view!.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
			enabled[i] = !((i == 0 && decks.isEmpty) || (i == 1 && Card.all().isEmpty))
			toggle(action.label!, action.barView!, enabled: enabled[i])
		}
	}
	
	@IBAction func showDecks() {
		guard enabled[0] else { return }
		performSegue(withIdentifier: "decks", sender: self)
	}
	
	@IBAction func showCards() {
		guard enabled[1] else { return }
		performSegue(withIdentifier: "cards", sender: self)
	}
	
	@IBAction func showCreate() {
		guard enabled[2] else { return }
		performSegue(withIdentifier: "createDeck", sender: self)
	}
	
	@IBAction func showMarketplace() {
		guard enabled[3] else { return }
		performSegue(withIdentifier: "searchDeck", sender: self)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cards.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UserCardsCollectionViewCell
		let element = cards[indexPath.item]
		cell.imageView.image = element.image
		cell.load(element.card.front)
		return cell
	}
}

class UserCardsCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var label: UILabel!
	
	func load(_ text: String) {
		layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		label.text = text.clean()
	}
}

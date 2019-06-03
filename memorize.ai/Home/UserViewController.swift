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
					let users = try managedContext.fetch(fetchRequest)
					if let user = users.first {
						let localEmail = user.value(forKey: "email") as? String
						loadProfileBarButtonItem(user.value(forKey: "image") as? Data)
						Auth.auth().signIn(withEmail: localEmail!, password: user.value(forKey: "password") as? String ?? "Error") { user, error in
							if error == nil, let uid = user?.user.uid {
								id = uid
								pushToken()
								listeners["users/\(uid)"] = firestore.document("users/\(uid)").addSnapshotListener { snapshot, error in
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
		updateCurrentViewController()
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
		listeners["settings"] = firestore.collection("settings").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot?.documentChanges else { return }
			snapshot.forEach {
				let setting = $0.document
				let settingId = setting.documentID
				switch $0.type {
				case .added:
					listeners["users/\(id)/settings/\(settingId)"] = firestore.document("users/\(id)/settings/\(settingId)").addSnapshotListener { settingSnapshot, settingError in
						guard settingError == nil, let settingSnapshot = settingSnapshot else { return }
						if let localSetting = Setting.get(settingId) {
							localSetting.update(settingSnapshot, type: .user)
							ChangeHandler.call(.settingValueModified)
						} else {
							settings.append(Setting(
								id: settingId,
								section: setting.get("section") as? String ?? "",
								slug: setting.get("slug") as? String ?? "",
								title: setting.get("title") as? String ?? "Error",
								description: setting.get("description") as? String ?? "",
								value: settingSnapshot.get("value"),
								default: setting.get("default") ?? true,
								order: setting.get("order") as? Int ?? 0
							))
							ChangeHandler.call(.settingAdded)
						}
						Setting.loadSectionedSettings()
						Setting.callHandler(settingId)
					}
				case .modified:
					Setting.get(settingId)?.update(setting, type: .setting)
					Setting.loadSectionedSettings()
					Setting.callHandler(settingId)
					ChangeHandler.call(.settingModified)
				case .removed:
					settings = settings.filter { return $0.id != settingId }
					Listener.remove("users/\(id)/settings/\(settingId)")
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
		listeners["users/\(id!)/decks"] = firestore.collection("users/\(id!)/decks").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot?.documentChanges else { return }
			snapshot.forEach {
				let deck = $0.document
				let deckId = deck.documentID
				switch $0.type {
				case .added:
					listeners["decks/\(deckId)"] = firestore.document("decks/\(deckId)").addSnapshotListener { deckSnapshot, deckError in
						guard deckError == nil, let deckSnapshot = deckSnapshot else { return }
						if let localDeck = Deck.get(deckId) {
							localDeck.update(deckSnapshot, type: .deck)
						} else {
							decks.append(Deck(
								id: deckId,
								image: nil,
								name: deckSnapshot.get("name") as? String ?? "Error",
								subtitle: deckSnapshot.get("subtitle") as? String ?? "Error",
								description: deckSnapshot.get("description") as? String ?? "Error",
								isPublic: deckSnapshot.get("public") as? Bool ?? true,
								count: deckSnapshot.get("count") as? Int ?? 0,
								views: DeckViews(deckSnapshot),
								downloads: DeckDownloads(deckSnapshot),
								ratings: DeckRatings(deckSnapshot),
								users: [],
								creator: deckSnapshot.get("creator") as? String ?? "Error",
								owner: deckSnapshot.get("owner") as? String ?? "Error",
								created: deckSnapshot.getDate("created") ?? Date(),
								updated: deckSnapshot.getDate("updated") ?? Date(),
								permissions: [],
								cards: [],
								mastered: deck.get("mastered") as? Int ?? 0
							))
						}
						ChangeHandler.call(.deckModified)
						listeners["decks/\(deckId)/cards"] = firestore.collection("decks/\(deckId)/cards").addSnapshotListener { snapshot, error in
							guard error == nil, let snapshot = snapshot?.documentChanges else { return }
							snapshot.forEach {
								let card = $0.document
								let cardId = card.documentID
								guard let localDeck = Deck.get(deckId) else { return }
								switch $0.type {
								case .added:
									listeners["users/\(id!)/decks/\(deckId)/cards/\(cardId)"] = firestore.document("users/\(id!)/decks/\(deckId)/cards/\(cardId)").addSnapshotListener { cardSnapshot, cardError in
										guard cardError == nil, let cardSnapshot = cardSnapshot else { return }
										if let localCard = Card.get(cardId, deckId: deckId) {
											localCard.update(cardSnapshot, type: .user)
										} else {
											localDeck.cards.append(Card(
												id: cardId,
												front: card.get("front") as? String ?? "Error",
												back: card.get("back") as? String ?? "Error",
												created: card.getDate("created") ?? Date(),
												updated: card.getDate("updated") ?? Date(),
												likes: card.get("likes") as? Int ?? 0,
												dislikes: card.get("dislikes") as? Int ?? 0,
												count: cardSnapshot.get("count") as? Int ?? 0,
												correct: cardSnapshot.get("correct") as? Int ?? 0,
												e: cardSnapshot.get("e") as? Double ?? 0,
												streak: cardSnapshot.get("streak") as? Int ?? 0,
												mastered: cardSnapshot.get("mastered") as? Bool ?? false,
												last: CardLast(cardSnapshot),
												next: cardSnapshot.getDate("next") ?? Date(),
												history: [],
												deck: deckId
											))
										}
										self.reloadReview()
										ChangeHandler.call(.cardModified)
									}
								case .modified:
									Card.get(cardId, deckId: deckId)?.update(card, type: .card)
									self.reloadReview()
									ChangeHandler.call(.cardModified)
								case .removed:
									localDeck.cards = localDeck.cards.filter { return $0.id != cardId }
									Listener.remove("users/\(id!)/decks/\(deckId)/cards/\(cardId)")
									self.reloadReview()
									ChangeHandler.call(.cardRemoved)
								@unknown default:
									return
								}
							}
						}
					}
				case .modified:
					Deck.get(deckId)?.update(deck, type: .user)
					ChangeHandler.call(.deckModified)
				case .removed:
					decks = decks.filter { return $0.id != deckId }
					Listener.remove("decks/\(deckId)")
					ChangeHandler.call(.deckRemoved)
				@unknown default:
					return
				}
			}
		}
	}
	
	func loadUploads() {
		firestore.collection("users/\(id!)/uploads").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot?.documentChanges else { return }
			snapshot.forEach {
				let upload = $0.document
				let uploadId = upload.documentID
				switch $0.type {
				case .added:
					uploads.append(Upload(
						id: uploadId,
						name: upload.get("name") as? String ?? "Error",
						created: upload.getDate("created") ?? Date(),
						updated: upload.getDate("updated") ?? Date(),
						data: nil,
						type: UploadType(rawValue: upload.get("type") as? String ?? "") ?? .image
					))
					ChangeHandler.call(.uploadAdded)
				case .modified:
					Upload.get(uploadId)?.update(upload)
					ChangeHandler.call(.uploadModified)
				case .removed:
					uploads = uploads.filter { return $0.id != uploadId }
					ChangeHandler.call(.uploadRemoved)
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
		(0...3).forEach {
			let action = actions[$0]
			action.view!.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
			enabled[$0] = !(($0 == 0 && decks.isEmpty) || ($0 == 1 && Card.all().isEmpty))
			toggle(action.label!, action.barView!, enabled: enabled[$0])
		}
	}
	
	@IBAction func showDecks() {
		guard enabled.first ?? false else { return }
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

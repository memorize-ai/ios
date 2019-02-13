import UIKit
import Firebase

class EditCardViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var editCardView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var frontLabel: UILabel!
	@IBOutlet weak var frontTextView: UITextView!
	@IBOutlet weak var backLabel: UILabel!
	@IBOutlet weak var backTextView: UITextView!
	@IBOutlet weak var historyTableView: UITableView!
	
	var deck: Deck?
	var card: Card?
	var history = [History]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners(corners: [.topLeft, .topRight], radius: 10)
		resetBorder(textView: frontTextView)
		resetBorder(textView: backTextView)
		frontTextView.text = card?.front
		backTextView.text = card?.back
		firestore.collection("users").document(id!).collection("decks").document(deck!.id).collection("cards").document(card!.id).collection("history").addSnapshotListener { snapshot, error in
			if let snapshot = snapshot?.documents, error == nil {
				self.history = snapshot.map { History(id: $0.documentID, date: $0["date"] as? Timestamp ?? Timestamp(), next: $0["next"] as? Timestamp ?? Timestamp(), correct: $0["correct"] as? Bool ?? false, elapsed: $0["elapsed"] as? Int ?? 0) }
				self.historyTableView.reloadData()
			} else if let error = error {
				self.showAlert(error.localizedDescription)
			}
		}
		editCardView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.editCardView.transform = .identity
		}, completion: nil)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		historyTableView.isScrollEnabled = false
		historyTableView.frame.size = historyTableView.contentSize
	}
	
	@IBAction func hide() {
		UIView.animate(withDuration: 0.2, animations: {
			self.editCardView.transform = CGAffineTransform(scaleX: 0, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				self.view.removeFromSuperview()
			}
		}
	}
	
	@IBAction func delete() {
		if deck?.owner == id {
			firestore.collection("decks").document(deck!.id).collection("cards").document(card!.id).delete { error in
				if error == nil {
					self.hide()
				} else if let error = error {
					self.showAlert(error.localizedDescription)
				}
			}
		} else {
			makeCopy()
		}
	}
	
	func makeCopy() {
//		let alertController = UIAlertController(title: "Make a copy", message: "You are not the owner of this deck", preferredStyle: .alert)
//		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//		let create = UIAlertAction(title: "Create", style: .default) { action in
//			let metadata = StorageMetadata()
//			metadata.contentType = "image/png"
//			let deckId = firestore.collection("decks").addDocument(data: ["name": self.deck!.name, "description": self.deck!.description, "public": self.deck!.isPublic, "count": self.deck!.cards.count, "owner": id!, "creator": ["id": id!, "name": name!]]).documentID
//			firestore.collection("users").document(id!).collection("decks").document(deckId).setData(["name": self.deck!.name, "count": self.deck!.cards.count, "mastered": 0])
//			storage.child("decks/\(deckId)").putData(image, metadata: metadata) { metadata, error in
//				if error == nil {
//					hide()
//				} else if let error = error {
//					self.hideActivityIndicator()
//					switch error.localizedDescription {
//					case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
//						self.showAlert("No internet")
//					default:
//						self.showAlert("There was a problem copying the deck")
//					}
//				}
//			}
//		}
//		alertController.addAction(cancel)
//		alertController.addAction(create)
//		present(alertController, animated: true, completion: nil)
	}
	
	func resetBorder(textView: UITextView) {
		textView.layer.borderWidth = 1
		textView.layer.borderColor = UIColor.lightGray.cgColor
	}
	
	func selectBorder(textView: UITextView) {
		textView.layer.borderWidth = 2
		textView.layer.borderColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
	}
	
	func redBorder(textView: UITextView) {
		textView.layer.borderWidth = 2
		textView.layer.borderColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if !textView.text.trim().isEmpty {
			selectBorder(textView: textView)
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		textView.text.trim().isEmpty ? redBorder(textView: textView) : resetBorder(textView: textView)
	}
	
	func textViewDidChange(_ textView: UITextView) {
		if deck?.owner == id {
			firestore.collection("decks").document(deck!.id).collection("cards").document(card!.id).updateData(textView == frontTextView ? ["front": frontTextView.text.trim()] : ["back": backTextView.text.trim()])
		} else {
			makeCopy()
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return history.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = history[indexPath.row]
		cell.textLabel?.text = element.date.format()
		cell.detailTextLabel?.text = element.correct ? "Correct" : "Wrong"
		return cell
	}
}

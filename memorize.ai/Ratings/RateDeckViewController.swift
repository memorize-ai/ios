import UIKit

class RateDeckViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
	@IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var star1Button: UIButton!
	@IBOutlet weak var star2Button: UIButton!
	@IBOutlet weak var star3Button: UIButton!
	@IBOutlet weak var star4Button: UIButton!
	@IBOutlet weak var star5Button: UIButton!
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var titleBarView: UIView!
	@IBOutlet weak var reviewTextView: UITextView!
	@IBOutlet weak var removeDraftButton: UIButton!
	@IBOutlet weak var removeDraftActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var removeDraftViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var deleteRatingButton: UIButton!
	@IBOutlet weak var deleteRatingActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var deleteRatingViewWidthConstraint: NSLayoutConstraint!
	
	var deck: Deck?
	var selectedRating: Int?
	var previousViewController: UIViewController?
	var submitAction: (() -> Void)?
	
	deinit {
		KeyboardHandler.removeListener(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "\(deck?.hasRating ?? false ? "Edit" : "New") Rating"
		load()
		reloadRightBarButton()
		reloadDestructiveButtons(animated: false)
		titleTextField.setKeyboard()
		reviewTextView.setKeyboard(.plain)
		textViewDidEndEditing(reviewTextView)
		removeDraftButton.layer.borderColor = DEFAULT_RED_COLOR.cgColor
		deleteRatingButton.layer.borderColor = DEFAULT_RED_COLOR.cgColor
		if let deckVC = previousViewController as? DeckViewController, let deck = deck {
			submitAction = {
				deckVC.listeners["decks/\(deck.id)/users"]?.remove()
				deckVC.loadRatings()
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.update { change in
			if change == .deckRatingAdded || change == .deckRatingRemoved || change == .ratingDraftAdded || change == .ratingDraftRemoved {
				self.reloadDestructiveButtons()
			} else if change == .deckRemoved && !(decks.contains { $0.id == self.deck?.id }) {
				self.navigationController?.popViewController(animated: true)
			}
		}
		KeyboardHandler.addListener(self, up: keyboardWillShow, down: keyboardWillHide)
		updateCurrentViewController()
	}
	
	var stars: [UIButton] {
		return [star1Button, star2Button, star3Button, star4Button, star5Button]
	}
	
	func keyboardWillShow() {
		scrollViewBottomConstraint.constant = keyboardOffset - view.safeAreaInsets.bottom
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: view.layoutIfNeeded, completion: nil)
	}
	
	func keyboardWillHide() {
		scrollViewBottomConstraint.constant = 0
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: view.layoutIfNeeded, completion: nil)
	}
	
	func load() {
		guard let deck = deck else { return }
		if let draft = deck.ratingDraft {
			reloadStars(updateSelectedRating(draft.rating))
			titleTextField.text = draft.title
			reviewTextView.text = draft.review
		} else if let rating = deck.rating {
			reloadStars(updateSelectedRating(rating.rating))
			titleTextField.text = rating.title
			reviewTextView.text = rating.review
		}
	}
	
	func updateSelectedRating(_ rating: Int?) -> Int {
		selectedRating = rating
		return rating ?? 0
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.titleBarView.transform = CGAffineTransform(scaleX: 1.01, y: 2)
			self.titleBarView.backgroundColor = DEFAULT_BLUE_COLOR
		}, completion: nil)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.titleBarView.transform = .identity
			self.titleBarView.backgroundColor = .lightGray
		}, completion: nil)
	}
	
	@IBAction
	func titleChanged() {
		updateDraft(selectedRating)
		reloadRightBarButton()
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		textView.layer.borderWidth = 2
		textView.layer.borderColor = DEFAULT_BLUE_COLOR.cgColor
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		textView.layer.borderWidth = 1
		textView.layer.borderColor = UIColor.lightGray.cgColor
	}
	
	func textViewDidChange(_ textView: UITextView) {
		updateDraft(selectedRating)
		reloadRightBarButton()
	}
	
	@IBAction
	func starSelected(_ sender: UIButton) {
		guard let index = stars.firstIndex(of: sender) else { return }
		let rating = updateSelectedRating(index + 1)
		reloadStars(rating)
		updateDraft(rating)
		reloadRightBarButton()
	}
	
	@IBAction
	func starDeselected() {
		reloadStars()
		updateDraft(updateSelectedRating(nil))
		reloadRightBarButton()
	}
	
	func reloadStars(_ rating: Int = 0) {
		(1...stars.count).forEach {
			stars[$0 - 1].setImage($0 > rating ? #imageLiteral(resourceName: "Unselected Star") : #imageLiteral(resourceName: "Selected Star"), for: .normal)
		}
	}
	
	func updateDraft(_ rating: Int?) {
		guard let id = id, let deck = deck else { return }
		firestore.document("users/\(id)/ratingDrafts/\(deck.id)").setData([
			"rating": rating ?? 0,
			"title": titleTextField.text ?? "",
			"review": reviewTextView.text ?? ""
		])
	}
	
	func reloadRightBarButton() {
		navigationItem.setRightBarButton(UIBarButtonItem(title: "Publish", style: .done, target: self, action: #selector(publish)), animated: false)
		if let rating = deck?.rating {
			setRightBarButton(!(rating.rating == selectedRating && rating.title == titleTextField.text?.trim() && rating.review == reviewTextView.text.trim()))
		} else {
			setRightBarButton(selectedRating != nil)
		}
	}
	
	func setRightBarButton(_ enabled: Bool) {
		guard let button = navigationItem.rightBarButtonItem else { return }
		button.isEnabled = enabled
		button.tintColor = enabled ? .white : #colorLiteral(red: 0.9841352105, green: 0.9841352105, blue: 0.9841352105, alpha: 1)
	}
	
	@objc
	func publish() {
		guard let id = id, let deck = deck else { return }
		showNotification("Publishing...", type: .normal)
		setRightBarButton(false)
		let isNew = !deck.hasRating
		deck.rate(selectedRating ?? 0, title: titleTextField.text?.trim() ?? "", review: reviewTextView.text.trim()) { error in
			if error == nil {
				firestore.document("users/\(id)/ratingDrafts/\(deck.id)").delete { error in
					if error == nil {
						self.setRightBarButton(false)
						buzz()
						self.submitAction?()
						if isNew {
							self.navigationController?.popViewController(animated: true)
						} else {
							self.showNotification("Published", type: .success)
						}
					} else {
						self.setRightBarButton(true)
					}
				}
			} else {
				self.setRightBarButton(true)
				self.showNotification("Unable to publish rating. Please try again", type: .error)
			}
		}
	}
	
	@IBAction
	func removeDraft() {
		guard let id = id, let deck = deck else { return }
		let alertController = UIAlertController(title: "Are you sure?", message: "This action cannot be undone", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
			self.setRemoveDraftLoading(true)
			firestore.document("users/\(id)/ratingDrafts/\(deck.id)").delete { error in
				self.setRemoveDraftLoading(false)
				if error == nil {
					buzz()
					if let rating = deck.rating {
						self.reloadStars(self.updateSelectedRating(rating.rating))
						self.titleTextField.text = rating.title
						self.reviewTextView.text = rating.review
						self.reloadRightBarButton()
						self.reloadDestructiveButtons()
						self.showNotification("Removed draft", type: .success)
					} else {
						self.navigationController?.popViewController(animated: true)
					}
				} else {
					self.showNotification("Unable to remove draft. Please try again", type: .error)
				}
			}
		})
		present(alertController, animated: true, completion: nil)
	}
	
	@IBAction
	func deleteRating() {
		guard let deck = deck else { return }
		let alertController = UIAlertController(title: "Are you sure?", message: "Your\(deck.hasRatingDraft ? " draft will be kept, but the" : "") published rating will be deleted. This action cannot be undone", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
			self.setDeleteRatingLoading(true)
			deck.unrate { error in
				self.setDeleteRatingLoading(false)
				if error == nil {
					buzz()
					if deck.hasRatingDraft {
						self.reloadRightBarButton()
						self.reloadDestructiveButtons()
						self.showNotification("Deleted rating", type: .success)
					} else {
						self.navigationController?.popViewController(animated: true)
					}
				} else {
					self.showNotification("Unable to delete rating. Please try again", type: .error)
				}
			}
		})
		present(alertController, animated: true, completion: nil)
	}
	
	func setRemoveDraftLoading(_ isLoading: Bool) {
		removeDraftButton.isEnabled = !isLoading
		removeDraftButton.setTitle(isLoading ? nil : "Remove draft", for: .normal)
		if isLoading {
			removeDraftActivityIndicator.startAnimating()
		} else {
			removeDraftActivityIndicator.stopAnimating()
		}
	}
	
	func setDeleteRatingLoading(_ isLoading: Bool) {
		deleteRatingButton.isEnabled = !isLoading
		deleteRatingButton.setTitle(isLoading ? nil : "Delete rating", for: .normal)
		if isLoading {
			deleteRatingActivityIndicator.startAnimating()
		} else {
			deleteRatingActivityIndicator.stopAnimating()
		}
	}
	
	func reloadDestructiveButtons(animated: Bool = true) {
		guard let deck = deck else { return }
		let hasDraft = deck.hasRatingDraft
		let hasRating = deck.hasRating
		let fullWidth = view.bounds.width - 40
		let halfWidth = view.bounds.width / 2 - 30
		switch true {
		case hasDraft && hasRating:
			removeDraftViewWidthConstraint.constant = halfWidth
			deleteRatingViewWidthConstraint.constant = halfWidth
		case hasDraft:
			removeDraftViewWidthConstraint.constant = fullWidth
			deleteRatingViewWidthConstraint.constant = 0
		case hasRating:
			removeDraftViewWidthConstraint.constant = 0
			deleteRatingViewWidthConstraint.constant = fullWidth
		default:
			removeDraftViewWidthConstraint.constant = 0
			deleteRatingViewWidthConstraint.constant = 0
		}
		UIView.animate(withDuration: animated ? 0.15 : 0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: view.layoutIfNeeded, completion: nil)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}

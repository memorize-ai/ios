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
	
	var deck: Deck?
	var selectedRating: Int?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "\(deck?.hasRating ?? false ? "Edit" : "New") Rating"
		load()
		reloadRightBarButton()
		titleTextField.setKeyboard()
		reviewTextView.setKeyboard(.plain)
		textViewDidEndEditing(reviewTextView)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		updateCurrentViewController()
	}
	
	var stars: [UIButton] {
		return [star1Button, star2Button, star3Button, star4Button, star5Button]
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		guard let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
		scrollViewBottomConstraint.constant = height - 30
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: view.layoutIfNeeded, completion: nil)
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
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
			self.titleBarView.backgroundColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
		}, completion: nil)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
			self.titleBarView.transform = .identity
			self.titleBarView.backgroundColor = .lightGray
		}, completion: nil)
	}
	
	@IBAction func titleChanged() {
		updateDraft(selectedRating)
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		textView.layer.borderWidth = 2
		textView.layer.borderColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		textView.layer.borderWidth = 1
		textView.layer.borderColor = UIColor.lightGray.cgColor
	}
	
	func textViewDidChange(_ textView: UITextView) {
		updateDraft(selectedRating)
	}
	
	@IBAction func starSelected(_ sender: UIButton) {
		guard let index = stars.firstIndex(of: sender) else { return }
		let rating = updateSelectedRating(index + 1)
		reloadStars(rating)
		updateDraft(rating)
		reloadRightBarButton()
	}
	
	@IBAction func starDeselected() {
		reloadStars()
		updateDraft(updateSelectedRating(nil))
		reloadRightBarButton()
	}
	
	func reloadStars(_ index: Int = 0) {
		(1...stars.count).forEach {
			stars[$0 - 1].setImage($0 > index ? #imageLiteral(resourceName: "Unselected Star") : #imageLiteral(resourceName: "Selected Star"), for: .normal)
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
			if let draft = deck?.ratingDraft {
				setRightBarButton(!(rating.rating == draft.rating && rating.title == draft.title && rating.review == draft.review))
			} else {
				setRightBarButton(false)
			}
		} else {
			setRightBarButton(selectedRating != nil)
		}
	}
	
	func setRightBarButton(_ enabled: Bool) {
		guard let button = navigationItem.rightBarButtonItem else { return }
		button.isEnabled = enabled
		button.tintColor = enabled ? .white : #colorLiteral(red: 0.9841352105, green: 0.9841352105, blue: 0.9841352105, alpha: 1)
	}
	
	@objc func publish() {
		guard let id = id, let deck = deck else { return }
		setRightBarButton(false)
		let isNew = !deck.hasRating
		deck.rate(selectedRating ?? 0, title: titleTextField.text?.trim() ?? "", review: reviewTextView.text.trim()) { error in
			if error == nil {
				firestore.document("users/\(id)/ratingDrafts/\(deck.id)").delete { error in
					if error == nil {
						self.setRightBarButton(false)
						buzz()
						if isNew {
							self.navigationController?.popViewController(animated: true)
						}
					} else {
						self.setRightBarButton(true)
					}
				}
			} else {
				self.setRightBarButton(true)
				self.showAlert("Unable to publish rating. Please try again")
			}
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}

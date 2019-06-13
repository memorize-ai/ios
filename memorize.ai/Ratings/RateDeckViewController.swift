import UIKit

class RateDeckViewController: UIViewController, UITextViewDelegate {
	@IBOutlet weak var star1Button: UIButton!
	@IBOutlet weak var star2Button: UIButton!
	@IBOutlet weak var star3Button: UIButton!
	@IBOutlet weak var star4Button: UIButton!
	@IBOutlet weak var star5Button: UIButton!
	@IBOutlet weak var reviewTextView: UITextView!
	
	var rating: DeckRating?
	var selectedRating: Int?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		load()
		reloadRightBarButton()
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
	
	func load() {
		guard let rating = rating else { return }
		if let draft = rating.draft {
			reloadStars((draft.rating ?? 1) - 1)
			reviewTextView.text = draft.review
		} else {
			reloadStars(rating.rating - 1)
			reviewTextView.text = rating.review
		}
	}
	
	@IBAction func starSelected(_ sender: UIButton) {
		guard let index = stars.firstIndex(of: sender) else { return }
		reloadStars(index)
	}
	
	@IBAction func starDeselected() {
		reloadStars()
	}
	
	func textViewDidChange(_ textView: UITextView) {
		reloadRightBarButton()
	}
	
	func reloadStars(_ index: Int = 0) {
		(0..<stars.count).forEach {
			stars[$0].setImage($0 > index ? #imageLiteral(resourceName: "Unselected Star") : #imageLiteral(resourceName: "Selected Star"), for: .normal)
		}
	}
	
	func reloadRightBarButton() {
		
	}
	
	func setRightBarButton(_ enabled: Bool) {
		guard let button = navigationItem.rightBarButtonItem else { return }
		button.isEnabled = enabled
		button.tintColor = enabled ? .white : #colorLiteral(red: 0.9841352105, green: 0.9841352105, blue: 0.9841352105, alpha: 1)
	}
	
	@objc func publish() {
		if let rating = rating {
			
		} else {
			
		}
	}
}

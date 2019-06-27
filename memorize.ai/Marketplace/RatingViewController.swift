import UIKit
import SafariServices

class RatingViewController: UIViewController {
	@IBOutlet weak var userImageView: UIImageView!
	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var ratingTitleLabel: UILabel!
	@IBOutlet weak var ratingStarsSliderView: UIView!
	@IBOutlet weak var ratingStarsSliderViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingDateLabel: UILabel!
	@IBOutlet weak var ratingNameLabel: UILabel!
	@IBOutlet weak var ratingReviewLabel: UILabel!
	
	var rating: DeckViewController.Rating?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction
	func userClicked() {
		if let url = rating?.user.url {
			present(SFSafariViewController(url: url), animated: true, completion: nil)
		} else {
			showNotification("Loading user...", type: .normal)
		}
	}
}

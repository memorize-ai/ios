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
		guard let rating = rating else { return }
		userImageView.image = rating.user.image
		userNameLabel.text = rating.user.name
		ratingTitleLabel.text = rating.rating.title
		ratingStarsSliderViewTrailingConstraint.constant = getStarsTrailingConstraint(width: ratingStarsSliderView.bounds.width, rating: Double(rating.rating.rating))
		ratingDateLabel.text = rating.rating.date.formatCompact()
		ratingNameLabel.text = rating.user.name
		let hasReview = rating.rating.hasReview
		ratingReviewLabel.text = hasReview ? rating.rating.review : "(no review)"
		ratingReviewLabel.textColor = hasReview ? .black : .darkGray
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

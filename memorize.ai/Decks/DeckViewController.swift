import UIKit

class DeckViewController: UIViewController {
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var getButton: UIButton!
	@IBOutlet weak var descriptionLabel: UILabel!
	
	var deckId: String?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		imageView.layer.borderWidth = 1
		imageView.layer.borderColor = UIColor.lightGray.cgColor
		firestore.collection("decks").document(deckId!).getDocument { snapshot, error in
			if error == nil {
				guard let snapshot = snapshot?.data() else { return }
				self.nameLabel.text = snapshot["name"] as? String ?? "Error"
				if Deck.id(self.deckId!) != nil {
					self.getButton.setTitle("DELETE", for: .normal)
					self.getButton.backgroundColor = #colorLiteral(red: 0.8459790349, green: 0.2873021364, blue: 0.2579272389, alpha: 1)
				}
				self.descriptionLabel.text = snapshot["description"] as? String ?? "Error"
				self.activityIndicator.stopAnimating()
				self.loadingView.isHidden = true
			} else {
				self.activityIndicator.stopAnimating()
				let alertController = UIAlertController(title: "Error", message: "Unable to load deck", preferredStyle: .alert)
				let action = UIAlertAction(title: "OK", style: .default) { action in
					self.navigationController?.popViewController(animated: true)
				}
				alertController.addAction(action)
				self.present(alertController, animated: true, completion: nil)
			}
		}
		storage.child("decks/\(self.deckId!)").getData(maxSize: 50000000) { data, error in
			if let data = data, error == nil {
				self.imageView.image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
			} else {
				self.showAlert("Unable to load image")
			}
		}
    }
	
	@IBAction func get() {
		if getButton.currentTitle == "GET" {
			firestore.collection("users").document(id!).collection("decks").document(deckId!).setData(["name": nameLabel.text!, "count": ]) { error in
				<#code#>
			}
		} else {
			// delete deck
		}
	}
}

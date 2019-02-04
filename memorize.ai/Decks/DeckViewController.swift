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
		loadingView.isHidden = false
		activityIndicator.startAnimating()
		firestore.collection("decks").document(deckId!).getDocument { snapshot, error in
			storage.child("decks/\(self.deckId!)").getData(maxSize: 50000000) { data, error in
				if let data = data, error == nil {
					guard let snapshot = snapshot?.data() else { return }
					self.imageView.image = UIImage(data: data) ?? #imageLiteral(resourceName: "Gray Deck")
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
					let alertController = UIAlertController(title: "Error", message: "Could not load deck", preferredStyle: .alert)
					let action = UIAlertAction(title: "OK", style: .default) { action in
						self.navigationController?.popViewController(animated: true)
					}
					alertController.addAction(action)
					self.present(alertController, animated: true, completion: nil)
				}
			}
		}
    }
	
	@IBAction func get() {
		if getButton.currentTitle == "GET" {
			// get deck
		} else {
			// delete deck
		}
	}
}

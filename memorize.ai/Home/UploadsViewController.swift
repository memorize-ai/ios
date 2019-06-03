import UIKit

class UploadsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var filterSegmentedControl: UISegmentedControl!
	@IBOutlet weak var uploadsCollectionView: UICollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Upload.loaded().count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		<#code#>
	}
}

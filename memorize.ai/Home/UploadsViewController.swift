import UIKit

class UploadsViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var filterSegmentedControl: UISegmentedControl!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var uploadsCollectionView: UICollectionView!
	
	var action: (() -> Void)?
	var filter: UploadType?
	var filteredUploads = [Upload]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let semiBold = UIFont(name: "Nunito-SemiBold", size: 18) {
			filterSegmentedControl.setTitleTextAttributes([
				.font: semiBold,
				.foregroundColor: UIColor.lightGray
			], for: .normal)
			filterSegmentedControl.setTitleTextAttributes([
				.font: semiBold,
				.foregroundColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
			], for: .selected)
		}
		let flowLayout = UICollectionViewFlowLayout()
		let size = view.bounds.width / 2 - 16
		flowLayout.itemSize = CGSize(width: size, height: size)
		uploadsCollectionView.collectionViewLayout = flowLayout
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.uploadAdded) { change in
			if change == .uploadAdded || change == .uploadModified || change == .uploadRemoved || change == .uploadLoaded {
				self.loadFilteredUploads()
				self.uploadsCollectionView.reloadData()
			}
		}
		updateCurrentViewController()
	}
	
	@IBAction func filterSegmentedControlChanged() {
		switch filterSegmentedControl.selectedSegmentIndex {
		case 0:
			filter = nil
		case 1:
			filter = .image
		case 2:
			filter = .gif
		case 3:
			filter = .audio
		default:
			return
		}
		loadFilteredUploads()
		uploadsCollectionView.reloadData()
	}
	
	@IBAction func upload() {
		performSegue(withIdentifier: "upload", sender: self)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		Algolia.search(.uploads, for: searchText) { results, error in
			guard error == nil else { return }
			self.filteredUploads = Upload.filter(results.compactMap {
				guard let uploadId = $0["objectID"] as? String, let upload = Upload.get(uploadId) else { return nil }
				return upload.data == nil ? nil : upload
			}, for: self.filter)
			self.uploadsCollectionView.reloadData()
		}
	}
	
	func loadFilteredUploads() {
		guard let searchText = searchBar.text else { return }
		if searchText.trim().isEmpty {
			let loaded = Upload.loaded()
			filteredUploads = Upload.filter(loaded, for: filter)
			if !uploads.isEmpty && loaded.isEmpty {
				uploads.first?.load { _, error in
					guard error == nil else { return }
					self.loadFilteredUploads()
					self.uploadsCollectionView.reloadData()
				}
			}
		} else {
			searchBar(searchBar, textDidChange: searchText)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return filteredUploads.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? UploadCollectionViewCell else { return _cell }
		let element = filteredUploads[indexPath.item]
		if let data = element.data {
			switch element.type {
			case .image, .gif:
				cell.imageView.image = UIImage(data: data)
			case .audio:
				cell.imageView.image = #imageLiteral(resourceName: "Sound")
			}
		} else {
			cell.imageView.image = nil
			cell.activityIndicator.startAnimating()
			element.load { data, error in
				cell.activityIndicator.stopAnimating()
				if error == nil, let data = data {
					cell.imageView.image = UIImage(data: data)
				} else {
					self.showAlert("There was a problem loading \(element.name)")
				}
			}
		}
		cell.nameLabel.text = element.name
		if indexPath.item == filteredUploads.count - 1 {
			let next = Upload.filter(Upload.getNext(5), for: filter)
			if !next.isEmpty {
				filteredUploads.append(contentsOf: next)
				uploadsCollectionView.reloadData()
			}
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let action = action {
			action()
		} else {
			
		}
	}
}

class UploadCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var nameLabel: UILabel!
}

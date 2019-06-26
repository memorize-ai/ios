import UIKit

class UploadsViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var allFilterButton: UIButton!
	@IBOutlet weak var imagesFilterButton: UIButton!
	@IBOutlet weak var gifsFilterButton: UIButton!
	@IBOutlet weak var audioFilterButton: UIButton!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var uploadsCollectionView: UICollectionView!
	
	var audioAllowed = true
	var completion: ((Upload) -> Void)?
	var filter: UploadType?
	var filteredUploads = [Upload]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let flowLayout = UICollectionViewFlowLayout()
		let size = view.bounds.width / 2 - 40
		flowLayout.itemSize = CGSize(width: size, height: size)
		uploadsCollectionView.collectionViewLayout = flowLayout
		if !audioAllowed {
			audioFilterButton.setTitleColor(#colorLiteral(red: 0.9601849914, green: 0.9601849914, blue: 0.9601849914, alpha: 1), for: .normal)
			audioFilterButton.isEnabled = false
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.uploadAdded) { change in
			if change == .uploadAdded || change == .uploadModified || change == .uploadRemoved || change == .uploadLoaded {
				self.reloadUploads()
			}
		}
		updateCurrentViewController()
	}
	
	func reloadUploads() {
		loadFilteredUploads()
		uploadsCollectionView.reloadData()
	}
	
	@IBAction func filterAll() {
		selectFilter(nil)
	}
	
	@IBAction func filterImages() {
		selectFilter(.image)
	}
	
	@IBAction func filterGifs() {
		selectFilter(.gif)
	}
	
	@IBAction func filterAudio() {
		selectFilter(.audio)
	}
	
	func deselectAllFilters() {
		([allFilterButton, imagesFilterButton, gifsFilterButton] + (audioAllowed ? [audioFilterButton] : [])).forEach {
			$0?.setTitleColor(.lightGray, for: .normal)
		}
	}
	
	func selectFilter(_ filter: UploadType?) {
		deselectAllFilters()
		self.filter = filter
		reloadUploads()
	}
	
	@IBAction func upload() {
		performSegue(withIdentifier: "upload", sender: self)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		Algolia.search(.uploads, for: searchText) { results, error in
			guard error == nil else { return }
			self.filteredUploads = self.filterForAudio(Upload.filter(results.compactMap {
				guard let uploadId = $0["objectID"] as? String else { return nil }
				return Upload.get(uploadId)
			}, for: self.filter))
			self.uploadsCollectionView.reloadData()
		}
	}
	
	func filterForAudio(_ uploads: [Upload]) -> [Upload] {
		return audioAllowed ? uploads : uploads.filter { $0.type != .audio }
	}
	
	func loadFilteredUploads() {
		guard let searchText = searchBar.text else { return }
		if searchText.trim().isEmpty {
			filteredUploads = filterForAudio(Upload.filter(uploads, for: filter))
		} else {
			searchBar(searchBar, textDidChange: searchText)
		}
	}
	
	func loadCell(_ cell: UploadCollectionViewCell, upload: Upload, data: Data) {
		cell.imageView.image = upload.image
		switch upload.type {
		case .image, .gif:
			cell.playButton.isHidden = true
		case .audio:
			cell.setPlayState(.ready)
			cell.playButton.isHidden = false
			cell.playAction = {
				if Audio.isPlaying {
					Audio.stop()
					cell.setPlayState(.ready)
				} else {
					cell.setPlayState(.stop)
					Audio.play(data: data) { success in
						cell.setPlayState(.ready)
						if !success {
							self.showNotification("Unable to play audio. Please try again", type: .error)
						}
					}
				}
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return filteredUploads.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? UploadCollectionViewCell else { return _cell }
		let upload = filteredUploads[indexPath.item]
		if let data = upload.data {
			loadCell(cell, upload: upload, data: data)
		} else {
			cell.imageView.image = nil
			cell.activityIndicator.startAnimating()
			upload.load { data, error in
				cell.activityIndicator.stopAnimating()
				if error == nil, let data = data {
					self.loadCell(cell, upload: upload, data: data)
				} else {
					self.showNotification("Unable to load \(upload.name)", type: .error)
				}
			}
		}
		cell.nameLabel.text = upload.name
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let upload = filteredUploads[indexPath.item]
		if let completion = completion {
			navigationController?.popViewController(animated: true)
			completion(upload)
		} else if let uploadActionsVC = storyboard?.instantiateViewController(withIdentifier: "uploadActions") as? UploadActionsViewController  {
			uploadActionsVC.upload = upload
			addChild(uploadActionsVC)
			uploadActionsVC.view.frame = view.frame
			view.addSubview(uploadActionsVC.view)
			uploadActionsVC.didMove(toParent: self)
		}
	}
}

class UploadCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var nameLabel: UILabel!
	
	var playAction: (() -> Void)?
	
	@IBAction func play() {
		playAction?()
	}
	
	func setPlayState(_ playState: Audio.PlayState) {
		playButton.setImage(Audio.image(for: playState), for: .normal)
	}
}

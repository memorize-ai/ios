import UIKit

class UploadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var chooseFileLabel: UILabel!
	@IBOutlet weak var fileImageView: UIImageView!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var nameBarView: UIView!
	@IBOutlet weak var metadataTableView: UITableView!
	@IBOutlet weak var uploadButton: UIButton!
	
	var file: (name: String, type: UploadType, mime: String, extension: String, size: String, data: Data)?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateCurrentViewController()
	}
	
	var metadata: [(key: String, value: String)] {
		guard let file = file else { return [] }
		let formatter = ByteCountFormatter()
		formatter.allowedUnits = [.useMB, .useGB]
		formatter.countStyle = .file
		return [
			("Size", formatter.string(fromByteCount: Int64(file.data.count))),
			("Type", file.type.formatted),
			("Ext", file.extension)
		]
	}
	
	@IBAction func chooseFile() {
		
	}
	
	@IBAction func upload() {
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return metadata.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = metadata[indexPath.row]
		cell.textLabel?.text = element.key
		cell.detailTextLabel?.text = element.value
		return cell
	}
}

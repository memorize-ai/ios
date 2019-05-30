import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var settingsTableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ChangeHandler.updateAndCall(.settingAdded) { change in
			if change == .settingAdded || change == .settingModified || change == .settingRemoved {
				self.settingsTableView.reloadData()
			}
		}
		updateCurrentViewController()
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return sectionedSettings.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sectionedSettings[section].section.title
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sectionedSettings[section].settings.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingTableViewCell
		cell.load(sectionedSettings[indexPath.section].settings[indexPath.row])
		return cell
	}
}

class SettingTableViewCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var valueSwitch: UISwitch!
	
	var setting: Setting?
	
	func load(_ setting: Setting) {
		self.setting = setting
		layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		titleLabel.text = setting.title
		descriptionLabel.text = setting.description
		valueSwitch.setOn(setting.data as? Bool ?? false, animated: false)
	}
	
	@IBAction func valueSwitchChanged() {
		guard let id = id, let setting = setting else { return }
		firestore.document("users/\(id)/settings/\(setting.id)").setData(["value": valueSwitch.isOn]) { error in
			if error == nil {
				Setting.callHandler(setting)
			} else {
				self.valueSwitch.setOn(!self.valueSwitch.isOn, animated: true)
			}
		}
	}
}

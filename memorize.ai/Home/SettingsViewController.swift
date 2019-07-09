import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var settingsTableView: UITableView!
	
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
		let _cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		guard let cell = _cell as? SettingTableViewCell else { return _cell }
		cell.load(sectionedSettings[indexPath.section].settings[indexPath.row])
		return cell
	}
}

class SettingTableViewCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var valueSwitch: UISwitch!
	
	var settingId: String?
	
	func load(_ setting: Setting) {
		settingId = setting.id
		layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
		titleLabel.text = setting.title
		descriptionLabel.text = setting.description
		valueSwitch.setOn(setting.data as? Bool ?? false, animated: false)
	}
	
	@IBAction
	func valueSwitchChanged() {
		guard let id = id, let settingId = settingId else { return }
		let isOn = valueSwitch.isOn
		firestore.document("users/\(id)/settings/\(settingId)").setData(["value": isOn]) { error in
			if error == nil {
				Setting.callHandler(settingId)
			} else {
				self.valueSwitch.setOn(!isOn, animated: true)
			}
		}
	}
}

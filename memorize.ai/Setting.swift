import Firebase

var settings = [Setting]()
var sectionedSettings = [SectionedSettings]()

class Setting {
	private static var handler: ((Setting) -> Void)?
	
	let id: String
	private var sectionSlug: String
	var section: SettingSection
	private var slug: String
	var type: SettingType
	var title: String
	var description: String
	var value: Any?
	var `default`: Any
	var order: Int
	
	init(id: String, section: String, slug: String, title: String, description: String, value: Any?, default: Any, order: Int) {
		self.id = id
		sectionSlug = section
		self.section = Setting.getSection(section)
		self.slug = slug
		type = Setting.getType(slug)
		self.title = title
		self.description = description
		self.value = value
		self.default = `default`
		self.order = order
	}
	
	var isDefault: Bool {
		return value == nil
	}
	
	var data: Any {
		return value ?? `default`
	}
	
	private static func getSection(_ slug: String) -> SettingSection {
		switch slug {
		case "general":
			return .general
		case "advanced":
			return .advanced
		default:
			return .unknown
		}
	}
	
	private static func getType(_ slug: String) -> SettingType {
		return SettingType(rawValue: slug) ?? .unknown
	}
	
	static func loadSectionedSettings() {
		sectionedSettings.removeAll()
		for setting in settings {
			if let section = (sectionedSettings.first { $0.section == setting.section }) {
				section.settings.append(setting)
				section.settings.sort { $0.order < $1.order }
			} else {
				sectionedSettings.append(SectionedSettings(section: setting.section, settings: [setting]))
			}
		}
		sectionedSettings.sort { $0.section.rawValue < $1.section.rawValue }
	}
	
	static func get(_ id: String) -> Setting? {
		return settings.first { return $0.id == id }
	}
	
	static func get(_ type: SettingType) -> Setting? {
		return settings.first { return $0.type == type }
	}
	
	private static func updateDarkMode(_ setting: Setting) {
		guard setting.type == .darkMode else { return }
		if setting.value == nil {
			defaults.removeObject(forKey: "darkMode")
		} else if let bool = setting.value as? Bool {
			defaults.set(bool, forKey: "darkMode")
		}
	}
	
	static func updateHandler(_ newHandler: ((Setting) -> Void)?) {
		handler = newHandler
		settings.forEach {
			handler?($0)
		}
	}
	
	static func callHandler(_ setting: Setting) {
		updateDarkMode(setting)
		handler?(setting)
	}
	
	static func callHandler(_ id: String) {
		guard let setting = get(id) else { return }
		callHandler(setting)
	}
	
	func update(_ snapshot: DocumentSnapshot, type: SettingUpdateType) {
		switch type {
		case .setting:
			section = Setting.getSection(snapshot.get("section") as? String ?? sectionSlug)
			self.type = Setting.getType(snapshot.get("slug") as? String ?? slug)
			title = snapshot.get("title") as? String ?? title
			description = snapshot.get("description") as? String ?? description
			`default` = snapshot.get("default") ?? `default`
			order = snapshot.get("order") as? Int ?? order
		case .user:
			value = snapshot.get("value")
		}
	}
}

class SectionedSettings {
	let section: SettingSection
	var settings: [Setting]
	
	init(section: SettingSection, settings: [Setting]) {
		self.section = section
		self.settings = settings
	}
}

enum SettingSection: Int {
	case general = 0
	case advanced = 1
	case unknown = -1
	
	var title: String {
		switch self {
		case .general:
			return "General"
		case .advanced:
			return "Advanced"
		case .unknown:
			return "Unknown"
		}
	}
}

enum SettingType: String {
	case darkMode = "dark-mode"
	case notifications = "notifications"
	case emailNotifications = "email-notifications"
	case algorithm = "algorithm"
	case unknown
}

enum SettingUpdateType {
	case setting
	case user
}

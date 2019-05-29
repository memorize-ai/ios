var settings = [Setting]()
var sectionedSettings = [SectionedSettings]()

class Setting {
	private static var handler: ((Setting) -> Void)?
	
	let id: String
	var sectionSlug: String
	var section: SettingSection
	let slug: String
	let type: SettingType
	var title: String
	var description: String
	var value: Any
	var order: Int
	
	init(id: String, section: String, slug: String, title: String, description: String, value: Any, order: Int) {
		self.id = id
		sectionSlug = section
		self.section = Setting.getSection(section)
		self.slug = slug
		type = Setting.getType(slug)
		self.title = title
		self.description = description
		self.value = value
		self.order = order
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
		switch slug {
		case "dark-mode":
			return .darkMode
		case "notifications":
			return .notifications
		case "algorithm":
			return .algorithm
		default:
			return .unknown
		}
	}
	
	static func loadSectionedSettings() {
		sectionedSettings.removeAll()
		for setting in settings {
			if let section = (sectionedSettings.filter { $0.section == setting.section }).first {
				section.settings.append(setting)
				section.settings.sort { $0.order < $1.order }
			} else {
				sectionedSettings.append(SectionedSettings(section: setting.section, settings: [setting]))
			}
		}
		sectionedSettings.sort { $0.section.rawValue < $1.section.rawValue }
	}
	
	static func id(_ t: String) -> Int? {
		for i in 0..<settings.count {
			if settings[i].id == t {
				return i
			}
		}
		return nil
	}
	
	static func get(_ type: SettingType) -> Setting? {
		return settings.first { $0.type == type }
	}
	
	static func get(_ slug: String) -> Setting? {
		return settings.first { $0.slug == slug }
	}
	
	static func updateHandler(_ newHandler: ((Setting) -> Void)?) {
		handler = newHandler
		settings.forEach {
			handler?($0)
		}
	}
	
	static func callHandler(_ setting: Setting) {
		handler?(setting)
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

enum SettingType {
	case darkMode
	case notifications
	case algorithm
	case unknown
}

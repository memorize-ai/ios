class ChangeHandler {
	private static var changeHandler: ((Change) -> Void)?
	
	static func call(_ change: Change) {
		changeHandler?(change)
	}
	
	static func update(_ handler: ((Change) -> Void)?) {
		changeHandler = handler
	}
	
	static func updateAndCall(_ changes: Change..., handler: ((Change) -> Void)?) {
		update(handler)
		changes.forEach {
			call($0)
		}
	}
}

enum Change {
	case profileModified
	case profilePicture
	case deckModified
	case deckRemoved
	case cardModified
	case cardRemoved
	case historyModified
	case historyRemoved
	case cardDue
	case settingAdded
	case settingValueModified
	case settingModified
	case settingRemoved
}

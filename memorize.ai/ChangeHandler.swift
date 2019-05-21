class ChangeHandler {
	private static var changeHandler: ((Change) -> Void)?
	
	static func call(_ change: Change) {
		changeHandler?(change)
	}
	
	static func update(_ handler: ((Change) -> Void)?) {
		changeHandler = handler
	}
	
	static func updateAndCall(_ change: Change, _ handler: ((Change) -> Void)?) {
		update(handler)
		call(change)
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
	case settingModified
	case settingRemoved
}

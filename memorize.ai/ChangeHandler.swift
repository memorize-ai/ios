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
		changes.forEach(call)
	}
}

enum Change {
	case keyboardMoved
	
	case profileModified
	case profilePicture
	
	case deckModified
	case deckRemoved
	
	case cardModified
	case cardRemoved
	case cardDue
	case cardNextModified
	
	case historyModified
	case historyRemoved
	
	case settingAdded
	case settingValueModified
	case settingModified
	case settingRemoved
	
	case uploadAdded
	case uploadModified
	case uploadRemoved
	case uploadLoaded
	
	case cardDraftAdded
	case cardDraftModified
	case cardDraftRemoved
	
	case deckRatingAdded
	case deckRatingModified
	case deckRatingRemoved
	
	case cardRatingAdded
	case cardRatingModified
	case cardRatingRemoved
	
	case ratingDraftAdded
	case ratingDraftModified
	case ratingDraftRemoved
	
	case ratingUserImageModified
}

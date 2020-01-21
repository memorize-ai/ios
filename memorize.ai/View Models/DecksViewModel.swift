import SwiftUI

final class DecksViewModel: ViewModel {
	@Published var isDeckOptionsPopUpShowing = false
	
	@Published var selectedSection: Deck.Section?
	@Published var isSectionOptionsPopUpShowing = false
	
	@Published var isDestroyAlertShowing = false
	@Published var isOrderSectionsSheetShowing = false
	
	@Published var expandedSections = [Deck.Section: Void]()
	
	func isSectionExpanded(_ section: Deck.Section) -> Bool {
		expandedSections[section] != nil
	}
	
	func toggleSectionExpanded(_ section: Deck.Section, forUser user: User) {
		if isSectionExpanded(section) {
			expandedSections[section] = nil
		} else {
			expandedSections[section] = ()
			section.loadCards(withUserDataForUser: user)
		}
	}
}

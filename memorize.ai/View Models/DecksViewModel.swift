import SwiftUI

final class DecksViewModel: ViewModel {
	@Published var isDeckOptionsPopUpShowing = false
	
	@Published var selectedSection: Deck.Section?
	@Published var isSectionOptionsPopUpShowing = false
	
	@Published var expandedSections = [Deck.Section]()
	
	func isSectionExpanded(_ section: Deck.Section) -> Bool {
		expandedSections.contains(section)
	}
	
	func toggleSectionExpanded(_ section: Deck.Section, forUser user: User) {
		if isSectionExpanded(section) {
			expandedSections.removeAll { $0 == section }
		} else {
			expandedSections.append(section)
			section.loadCards(withUserDataForUser: user)
		}
	}
}

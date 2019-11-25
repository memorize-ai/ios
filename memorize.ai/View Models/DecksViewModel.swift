import SwiftUI

final class DecksViewModel: ObservableObject {
	@Published var isDeckOptionsPopUpShowing = false
	
	@Published var selectedSection: Deck.Section!
	@Published var isSectionOptionsPopUpShowing = false
	
	@Published var expandedSections = [Deck.Section]()
	
	func isSectionExpanded(_ section: Deck.Section) -> Bool {
		expandedSections.contains(section)
	}
	
	func toggleSectionExpanded(_ section: Deck.Section) {
		isSectionExpanded(section)
			? expandedSections.removeAll { $0 == section }
			: expandedSections.append(section)
	}
}

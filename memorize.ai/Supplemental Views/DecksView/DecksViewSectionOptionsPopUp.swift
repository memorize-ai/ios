import SwiftUI

struct DecksViewSectionOptionsPopUp: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var deck: Deck
	@ObservedObject var section: Deck.Section
	
	var isOwner: Bool {
		deck.creatorId == currentStore.user.id
	}
	
	var body: some View {
		PopUp(
			isShowing: $model.isSectionOptionsPopUpShowing,
			contentHeight: 50 * 0 + 0
		) {
			// If owner:
			//  "Review"
			//  "Add cards"
			//  "Edit"
			//  "Share unlock link"
			//  -- DIVIDER --
			//  "Delete"
			
			// If not owner:
			//  "Review"
			//  "Unlock" / "Lock"
			
			EmptyView()
		}
	}
}

#if DEBUG
struct DecksViewSectionOptionsPopUp_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewSectionOptionsPopUp(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			section: .init(
				id: "0",
				parent: PREVIEW_CURRENT_STORE.user.decks.first!,
				name: "CSS",
				numberOfCards: 56
			)
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
		.environmentObject(DecksViewModel())
	}
}
#endif

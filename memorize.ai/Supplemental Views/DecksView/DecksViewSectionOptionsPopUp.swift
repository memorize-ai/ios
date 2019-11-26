import SwiftUI

struct DecksViewSectionOptionsPopUp: View {
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var section: Deck.Section
	
	var body: some View {
		PopUp(
			isShowing: $model.isSectionOptionsPopUpShowing,
			contentHeight: 50 * 0 + 0
		) {
			// TODO: Add content
		}
	}
}

#if DEBUG
struct DecksViewSectionOptionsPopUp_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewSectionOptionsPopUp(section: .init(
			id: "0",
			name: "CSS",
			numberOfCards: 56
		))
		.environmentObject(DecksViewModel())
	}
}
#endif

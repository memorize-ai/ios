import SwiftUI

struct DecksViewDeckOptionsPopUp: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: DecksViewModel
	
	var selectedDeck: Deck? {
		currentStore.selectedDeck
	}
	
	var isFavorite: Bool {
		selectedDeck?.userData?.isFavorite ?? false
	}
	
	func resizeImage(_ image: Image) -> some View {
		image
			.resizable()
			.renderingMode(.original)
			.aspectRatio(contentMode: .fit)
			.frame(width: 21, height: 21)
	}
	
	var body: some View {
		PopUp(
			isShowing: $model.isDeckOptionsPopUpShowing,
			contentHeight: 50 * 1 + 0
		) {
			PopUpButton(
				icon: resizeImage(
					isFavorite
						? .selectedPurpleStarIcon
						: .purpleStarIcon
				),
				text: "\(isFavorite ? "Remove from" : "Add to") favorites",
				textColor: .darkGray
			) {
				// TODO: Toggle favorite
			}
		}
	}
}

#if DEBUG
struct DecksViewDeckOptionsPopUp_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewDeckOptionsPopUp()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(DecksViewModel())
	}
}
#endif

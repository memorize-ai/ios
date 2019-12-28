import SwiftUI

struct DecksViewDeckOptionsPopUp: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var selectedDeck: Deck
		
	var isOwner: Bool {
		selectedDeck.creatorId == currentStore.user.id
	}
	
	var isFavorite: Bool {
		selectedDeck.userData?.isFavorite ?? false
	}
	
	func resizeImage(_ image: Image, dimension: CGFloat = 21) -> some View {
		image
			.resizable()
			.renderingMode(.original)
			.aspectRatio(contentMode: .fit)
			.frame(width: dimension, height: dimension)
	}
	
	var body: some View {
		PopUp(
			isShowing: $model.isDeckOptionsPopUpShowing,
			contentHeight: .init(50 * (isOwner ? 7 : 5) + 2)
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
				self.selectedDeck.userData?.isFavorite.toggle()
				self.selectedDeck.setFavorite(
					to: self.isFavorite,
					forUser: self.currentStore.user
				)
			}
			PopUpButton(
				icon: Group {
					if selectedDeck.creatorLoadingState.isLoading {
						ActivityIndicator(color: .darkBlue)
					} else {
						Image(systemName: .squareAndArrowUp)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.foregroundColor(.darkBlue)
					}
				}
				.frame(width: 21, height: 21),
				text: "Share",
				textColor: .darkGray
			) {
				share(items: [self.selectedDeck.shareMessage])
			}
			.disabled(!selectedDeck.creatorLoadingState.didSucceed)
			.onAppear {
				self.selectedDeck.loadCreator()
			}
			if isOwner {
				PopUpButton(
					icon: resizeImage(.editSectionsIcon),
					text: "Edit sections",
					textColor: .darkGray
				) {
					// TODO: Edit sections
				}
			}
			PopUpButton(
				icon: resizeImage(.performanceCheckIcon),
				text: "Performance",
				textColor: .darkGray
			) {
				// TODO: View performance
			}
			PopUpDivider()
			PopUpButton(
				icon: resizeImage(.purpleShoppingCartIcon),
				text: "Visit page",
				textColor: .darkGray
			) {
				// TODO: Visit marketplace page
			}
			PopUpDivider()
			PopUpButton(
				icon: XButton(.purple, height: 15)
					.padding(.horizontal, 2.5),
				text: "Remove from library",
				textColor: .darkGray
			) {
				// TODO: Removed deck from user library
			}
			if isOwner {
				PopUpButton(
					icon: resizeImage(.trashIcon),
					text: "Destroy",
					textColor: .darkGray
				) {
					// TODO: Remove deck from marketplace
				}
			}
		}
	}
}

#if DEBUG
struct DecksViewDeckOptionsPopUp_Previews: PreviewProvider {
	static var previews: some View {
		let model = DecksViewModel()
		model.isDeckOptionsPopUpShowing = true
		return DecksViewDeckOptionsPopUp(
			selectedDeck: PREVIEW_CURRENT_STORE.user.decks.first!
		)
		.environmentObject(PREVIEW_CURRENT_STORE)
		.environmentObject(model)
	}
}
#endif

import SwiftUI

struct DecksViewDeckOptionsPopUp: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var selectedDeck: Deck
	
	@Binding var isDeckOptionsPopUpShowing: Bool
	@Binding var isOrderSectionsSheetShowing: Bool
	
	let geometry: GeometryProxy
		
	var isOwner: Bool {
		selectedDeck.creatorId == currentStore.user.id
	}
	
	var isFavorite: Bool {
		selectedDeck.userData?.isFavorite ?? false
	}
	
	var canOrderSections: Bool {
		selectedDeck.sections.count > 1
	}
	
	func hide() {
		popUpWithAnimation {
			isDeckOptionsPopUpShowing = false
		}
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
			isShowing: $isDeckOptionsPopUpShowing,
			contentHeight: .init(
				50 * (isOwner ? (8 + *canOrderSections) : 5) +
				1 + *isOwner
			),
			geometry: geometry
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
				icon: Image(systemName: .squareAndArrowUp)
					.resizable()
					.foregroundColor(.darkBlue)
					.aspectRatio(contentMode: .fit)
					.frame(width: 21, height: 21),
				text: "Share",
				textColor: .darkGray
			) {
				guard let url = self.selectedDeck.getUrl else {
					return showAlert(
						title: "An unknown error occurred",
						message: "Please try again"
					)
				}
				
				share(url, corner: .topLeft)
			}
			if isOwner {
				PublishDeckViewNavigationLink(deck: selectedDeck) {
					HStack(spacing: 20) {
						resizeImage(.editSectionsIcon)
						Text("Edit")
							.font(.muli(.semiBold, size: 17))
							.foregroundColor(.darkGray)
						Spacer()
					}
					.padding(.horizontal, 30)
				}
				.frame(height: 50)
				PopUpDivider()
				PopUpButton(
					icon: Image(systemName: .plusCircle)
						.resizable()
						.aspectRatio(contentMode: .fit)
						.foregroundColor(.darkBlue)
						.frame(width: 21, height: 21),
					text: "Add new section",
					textColor: .darkGray
				) {
					self.selectedDeck.showCreateSectionAlert { _ in
						self.hide()
					}
				}
				if canOrderSections {
					PopUpButton(
						icon: resizeImage(.editSectionsIcon),
						text: "Order sections",
						textColor: .darkGray
					) {
						self.isOrderSectionsSheetShowing = true
					}
					.sheet(isPresented: $isOrderSectionsSheetShowing) {
						DecksViewOrderSectionsSheetView(deck: self.selectedDeck)
					}
				}
			}
			PopUpDivider()
			NavigationLink(
				destination: MarketDeckView()
					.environmentObject(selectedDeck)
					.navigationBarRemoved()
			) {
				HStack(spacing: 20) {
					resizeImage(.purpleShoppingCartIcon)
					Text("Visit page")
						.font(.muli(.semiBold, size: 17))
						.foregroundColor(.darkGray)
					Spacer()
				}
				.padding(.horizontal, 30)
			}
			.frame(height: 50)
			PopUpDivider()
			PopUpButton(
				icon: XButton(.purple, height: 15)
					.padding(.horizontal, 2.5),
				text: "Remove from library",
				textColor: .darkGray
			) {
				self.selectedDeck.showRemoveFromLibraryAlert(
					forUser: self.currentStore.user,
					onConfirm: {
						popUpWithAnimation {
							self.isDeckOptionsPopUpShowing = false
							self.currentStore.reloadSelectedDeck()
						}
					}
				)
			}
			if isOwner {
				PopUpButton(
					icon: resizeImage(.trashIcon),
					text: "Destroy",
					textColor: .darkGray
				) {
					showAlert(
						title: "Are you sure?",
						message: "\(self.selectedDeck.name) and all of its content will be deleted. This cannot be undone."
					) { alert in
						alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
						alert.addAction(.init(title: "Destroy", style: .destructive) { _ in
							self.selectedDeck.delete()
							popUpWithAnimation {
								self.isDeckOptionsPopUpShowing = false
								self.currentStore.reloadSelectedDeck()
							}
						})
					}
				}
			}
		}
	}
}

#if DEBUG
struct DecksViewDeckOptionsPopUp_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geometry in
			DecksViewDeckOptionsPopUp(
				selectedDeck: PREVIEW_CURRENT_STORE.user.decks.first!,
				isDeckOptionsPopUpShowing: .constant(true),
				isOrderSectionsSheetShowing: .constant(false),
				geometry: geometry
			)
		}
	}
}
#endif

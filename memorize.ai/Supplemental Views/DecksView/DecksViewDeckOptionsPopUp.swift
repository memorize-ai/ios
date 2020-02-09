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
	
	var canOrderSections: Bool {
		selectedDeck.sections.count > 1
	}
	
	func hide() {
		popUpWithAnimation {
			model.isDeckOptionsPopUpShowing = false
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
			isShowing: $model.isDeckOptionsPopUpShowing,
			contentHeight: .init(
				50 * (isOwner ? (8 + *canOrderSections) : 5) +
				2 + *isOwner
			)
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
				guard let message = self.selectedDeck.shareMessage else {
					return showAlert(
						title: "An unknown error occurred",
						message: "Please try again"
					)
				}
				
				share(message)
			}
			.disabled(!selectedDeck.creatorLoadingState.didSucceed)
			.onAppear {
				self.selectedDeck.loadCreator()
			}
			PopUpButton(
				icon: Image(systemName: .link)
					.resizable()
					.foregroundColor(.darkBlue)
					.aspectRatio(contentMode: .fit)
					.frame(width: 21, height: 21),
				text: "Share get link",
				textColor: .darkGray
			) {
				guard let url = self.selectedDeck.getUrl else {
					return showAlert(
						title: "An unknown error occurred",
						message: "Please try again"
					)
				}
				
				share(url)
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
						self.model.isOrderSectionsSheetShowing = true
					}
					.sheet(isPresented: $model.isOrderSectionsSheetShowing) {
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
					forUser: self.currentStore.user
				) {
					popUpWithAnimation {
						self.model.isDeckOptionsPopUpShowing = false
						self.currentStore.reloadSelectedDeck()
					}
				}
			}
			if isOwner {
				PopUpButton(
					icon: resizeImage(.trashIcon),
					text: "Destroy",
					textColor: .darkGray
				) {
					self.model.isDestroyAlertShowing = true
				}
				.alert(isPresented: $model.isDestroyAlertShowing) {
					.init(
						title: .init("Are you sure?"),
						message: .init("\(selectedDeck.name) and all of its content will be deleted. This cannot be undone."),
						primaryButton: .destructive(.init("Destroy")) {
							self.selectedDeck.delete()
							popUpWithAnimation {
								self.model.isDeckOptionsPopUpShowing = false
								self.currentStore.reloadSelectedDeck()
							}
						},
						secondaryButton: .cancel()
					)
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

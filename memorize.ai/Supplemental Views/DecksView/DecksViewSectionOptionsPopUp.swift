import SwiftUI

struct DecksViewSectionOptionsPopUp: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var deck: Deck
	@ObservedObject var section: Deck.Section
	
	var isOwner: Bool {
		deck.creatorId == currentStore.user.id
	}
	
	var isUnlocked: Bool {
		section.isUnlocked
	}
	
	var hasCards: Bool {
		section.numberOfCards > 0
	}
	
	var contentHeight: CGFloat {
		.init(
			50 * (
				(isUnlocked ? (*section.isDue + *hasCards) : 1) +
				(isOwner ? 2 : 0) +
				*(!section.isUnsectioned)
			) +
			(isOwner ? 2 : 0)
		)
	}
	
	func hide() {
		popUpWithAnimation {
			model.isSectionOptionsPopUpShowing = false
		}
	}
	
	var reviewIcon: some View {
		ZStack(alignment: .topLeading) {
			RoundedRectangle(cornerRadius: 4)
				.stroke(Color.darkBlue.opacity(0.5), lineWidth: 1.5)
				.frame(width: 20, height: 14)
				.padding([.leading, .top], 3)
			ZStack {
				RoundedRectangle(cornerRadius: 4)
					.stroke(Color.darkBlue, lineWidth: 1.5)
					.background(Color.white)
				Text(section.numberOfDueCards?.formatted ?? "")
					.font(.muli(.bold, size: 11))
					.foregroundColor(.darkBlue)
					.shrinks()
			}
			.frame(width: 20, height: 14)
		}
	}
	
	var learnIcon: some View {
		VStack(alignment: .leading, spacing: 4) {
			Group {
				Capsule()
					.frame(width: 21)
				Capsule()
					.frame(width: 21 / 2)
				Capsule()
					.frame(width: 21 * 2 / 3)
			}
			.foregroundColor(.darkBlue)
			.frame(height: 2)
		}
	}
	
	var body: some View {
		PopUp(
			isShowing: $model.isSectionOptionsPopUpShowing,
			contentHeight: contentHeight
		) {
			if isUnlocked {
				if section.isDue {
					ReviewViewNavigationLink(section: section) {
						HStack(spacing: 20) {
							reviewIcon
							Text("Review")
								.font(.muli(.semiBold, size: 17))
								.foregroundColor(.darkGray)
							Spacer()
						}
						.padding(.horizontal, 30)
						.frame(height: 50)
					}
				}
				if hasCards {
					LearnViewNavigationLink(section: section) {
						HStack(spacing: 20) {
							learnIcon
							Text("Learn")
								.font(.muli(.semiBold, size: 17))
								.foregroundColor(.darkGray)
							Spacer()
						}
						.padding(.horizontal, 30)
						.frame(height: 50)
					}
				}
			} else {
				PopUpButton(
					icon: Image(systemName: .lockSlashFill)
						.resizable()
						.foregroundColor(.darkBlue)
						.aspectRatio(contentMode: .fit)
						.frame(width: 21, height: 21),
					text: "Unlock",
					textColor: .darkGray
				) {
					self.section.showUnlockAlert(
						forUser: self.currentStore.user,
						completion: self.hide
					)
				}
			}
			if isOwner {
				PopUpDivider()
				PopUpButton(
					icon: Image.editSectionsIcon
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 21, height: 21),
					text: "Rename",
					textColor: .darkGray
				) {
					self.section.showRenameAlert()
				}
			}
			if !section.isUnsectioned {
				PopUpButton(
					icon: Image(systemName: .link)
						.resizable()
						.foregroundColor(.darkBlue)
						.aspectRatio(contentMode: .fit)
						.frame(width: 21, height: 21),
					text: "Share unlock link",
					textColor: .darkGray
				) {
					share(items: [self.section.unlockLink])
				}
			}
			if isOwner {
				PopUpDivider()
				PopUpButton(
					icon: Image.trashIcon
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 21, height: 21),
					text: "Delete",
					textColor: .darkGray
				) {
					self.section.showDeleteAlert(completion: self.hide)
				}
			}
		}
	}
}

#if DEBUG
struct DecksViewSectionOptionsPopUp_Previews: PreviewProvider {
	static var previews: some View {
		let model = DecksViewModel()
		model.isSectionOptionsPopUpShowing = true
		return ZStack {
			Color.blue
				.edgesIgnoringSafeArea(.all)
			DecksViewSectionOptionsPopUp(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: .init(
					id: "0",
					parent: PREVIEW_CURRENT_STORE.user.decks.first!,
					name: "CSS",
					index: 0,
					numberOfCards: 56
				)
			)
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(model)
		}
	}
}
#endif

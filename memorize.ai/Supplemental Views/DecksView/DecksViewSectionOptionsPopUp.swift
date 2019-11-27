import SwiftUI

struct DecksViewSectionOptionsPopUp: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var deck: Deck
	@ObservedObject var section: Deck.Section
	
	var isOwner: Bool {
		deck.creatorId == currentStore.user.id
	}
	
	var isLocked: Bool {
		!section.isUnlocked
	}
	
	var contentHeight: CGFloat {
		.init(50 * (*section.isDue + 1 + (isOwner ? 4 : *isLocked)) + *isOwner)
	}
	
	func reviewIcon(withText text: String? = nil) -> some View {
		ZStack(alignment: .topLeading) {
			RoundedRectangle(cornerRadius: 4)
				.stroke(Color.darkBlue.opacity(0.5), lineWidth: 1.5)
				.frame(width: 20, height: 14)
				.padding([.leading, .top], 3)
			ZStack {
				RoundedRectangle(cornerRadius: 4)
					.stroke(Color.darkBlue, lineWidth: 1.5)
					.background(Color.white)
				if text != nil {
					Text(text ?? "")
						.font(.muli(.bold, size: 11))
						.foregroundColor(.darkBlue)
						.minimumScaleFactor(0.2)
				}
			}
			.frame(width: 20, height: 14)
		}
	}
	
	var body: some View {
		PopUp(
			isShowing: $model.isSectionOptionsPopUpShowing,
			contentHeight: contentHeight
		) {
			if section.isDue {
				PopUpButton(
					icon: reviewIcon(
						withText: section.numberOfDueCards.formatted
					),
					text: "Review",
					textColor: .darkGray
				) {
					// TODO: Review section
				}
			}
			PopUpButton(
				icon: reviewIcon(),
				text: "Review all",
				textColor: .darkGray
			) {
				// TODO: Review all cards in section
			}
			if isOwner {
				PopUpButton(
					icon: Image(systemName: .plusCircle)
						.resizable()
						.foregroundColor(.darkBlue)
						.frame(width: 21, height: 21),
					text: "Add cards",
					textColor: .darkGray
				) {
					// TODO: Add cards
				}
				PopUpButton(
					icon: Image.editSectionsIcon
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 21, height: 21),
					text: "Edit",
					textColor: .darkGray
				) {
					// TODO: Edit section
				}
				PopUpButton(
					icon: nil as EmptyView?, // TODO: Replace with link icon
					text: "Share unlock link",
					textColor: .darkGray
				) {
					// TODO: Share unlock link
				}
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
					// TODO: Delete section
				}
			} else if isLocked {
				PopUpButton(
					icon: nil as EmptyView?, // TODO: Replace with unlock icon
					text: "Unlock",
					textColor: .darkGray
				) {
					// TODO: Unlock section
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
					numberOfCards: 56
				)
			)
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(model)
		}
	}
}
#endif

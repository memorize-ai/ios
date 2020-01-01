import SwiftUI

struct EditCardViewCardCell: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var model: EditCardViewModel
	@EnvironmentObject var card: Card.Draft
	
	var title: String {
		let cardTitle = card.title
		return cardTitle.isEmpty
			? "NEW CARD"
			: cardTitle
	}
	
	var isSectionLoading: Bool {
		card.sectionId != nil && card.section == nil
	}
	
	var sectionTitle: String {
		card.section?.name ?? "Unsectioned"
	}
	
	func headerText(_ text: String) -> some View {
		Text(text)
			.font(.muli(.bold, size: 15))
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.top, 2)
	}
	
	func editor(html: Binding<String>) -> some View {
		CustomRectangle(
			background: Color.white,
			borderColor: Color.gray.opacity(0.2),
			borderWidth: 1
		) {
			FroalaEditor(html: html)
				.frame(height: 200)
		}
	}
	
	var topControls: some View {
		HStack(alignment: .bottom, spacing: 20) {
			Text(title)
				.font(.muli(.extraBold, size: 15))
				.foregroundColor(.white)
			Spacer()
			if card.publishLoadingState.isLoading {
				ActivityIndicator(color: .white)
			} else {
				Button(action: {
					self.card.showDeleteAlert {
						self.presentationMode.wrappedValue.dismiss()
					}
				}) {
					Image.whiteTrashIcon
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(height: 17)
				}
			}
		}
	}
	
	var section: some View {
		Button(action: {
			popUpWithAnimation {
				self.model.isAddSectionPopUpShowing = true
			}
		}) {
			CustomRectangle(
				background: Color.mediumGray.opacity(0.68)
			) {
				HStack {
					if isSectionLoading {
						ActivityIndicator(color: .lightGrayText)
					} else {
						Text(sectionTitle)
							.font(.muli(.regular, size: 18))
							.foregroundColor(.lightGrayText)
					}
					Spacer()
					Image.grayDropDownArrowHead
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 20)
						.padding(.vertical)
				}
				.padding(.horizontal)
			}
		}
	}
	
	var body: some View {
		VStack(spacing: 8) {
			topControls
				.padding(.horizontal, 6)
			CustomRectangle(
				background: Color.white
			) {
				VStack {
					section
					Rectangle()
						.foregroundColor(.lightGrayBorder)
						.frame(height: 1)
					headerText("FRONT")
					editor(html: $card.front)
					headerText("BACK")
					editor(html: $card.back)
				}
				.padding()
			}
		}
	}
}

#if DEBUG
struct EditCardViewCardCell_Previews: PreviewProvider {
	static var previews: some View {
		EditCardViewCardCell()
			.environmentObject(EditCardViewModel())
			.environmentObject(Card.Draft(
				parent: PREVIEW_CURRENT_STORE.user.decks.first!
			))
	}
}
#endif

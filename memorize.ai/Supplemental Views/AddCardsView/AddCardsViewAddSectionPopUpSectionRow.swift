import SwiftUI

struct AddCardsViewAddSectionPopUpSectionRow: View {
	@ObservedObject var section: Deck.Section
	@ObservedObject var card: Card.Draft
	
	var isSelected: Bool {
		card.sectionId == section.id
	}
	
	var body: some View {
		Button(action: {
			self.card.section = self.section
		}) {
			HStack(spacing: 20) {
				if isSelected {
					Image.blueCheck
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 20)
				}
				Text(section.name)
					.font(.muli(.semiBold, size: 17))
					.foregroundColor(isSelected ? .darkBlue : .darkGray)
				Spacer()
				Text("(\(section.numberOfCards.formatted))")
					.font(.muli(.semiBold, size: 17))
					.foregroundColor(.darkGray)
				Button(action: {
					self.section.showRenameAlert()
				}) {
					Image.pencil
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 19)
				}
				Button(action: {
					self.section.showDeleteAlert {
						guard self.isSelected else { return }
						self.card.section = nil
					}
				}) {
					Image.grayTrashIcon
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 17)
				}
			}
			.frame(height: 22)
			.padding(.leading, 25)
			.padding(.trailing, 30)
			.padding(.vertical, 12)
		}
	}
}

#if DEBUG
struct AddCardsViewAddSectionPopUpSectionRow_Previews: PreviewProvider {
	static var previews: some View {
		AddCardsViewAddSectionPopUpSectionRow(
			section: PREVIEW_CURRENT_STORE.user.decks[0].sections[0],
			card: .init(
				parent: PREVIEW_CURRENT_STORE.user.decks[0],
				card: PREVIEW_CURRENT_STORE.user.decks[0].previewCards[0]
			)
		)
	}
}
#endif

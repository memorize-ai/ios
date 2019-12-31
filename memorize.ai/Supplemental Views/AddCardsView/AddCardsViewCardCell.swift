import SwiftUI
import WebView

struct AddCardsViewCardCell: View {
	@EnvironmentObject var model: AddCardsViewModel
	
	@ObservedObject var deck: Deck
	@ObservedObject var card: Card.Draft
	
	init(card: Card.Draft) {
		deck = card.parent
		self.card = card
	}
	
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
					self.model.removeCard(self.card)
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
			self.model.currentCard = self.card
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
	
	var front: some View {
		WebView(
			html: """
			<!DOCTYPE html>
			<html>
				<head>
					<link rel="stylesheet" href="froala.css">
					<script src="froala.js"></script>
				</head>
				<body>
					<div id="editor"></div>
					<script>
						new FroalaEditor('#editor')
					</script>
				</body>
			</html>
			""",
			baseURL: .init(fileURLWithPath: Bundle.main.bundlePath, isDirectory: true)
		)
		.frame(height: 200)
	}
	
	var back: some View {
		Text("Back")
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
					Text("FRONT")
						.font(.muli(.bold, size: 15))
						.frame(maxWidth: .infinity, alignment: .leading)
					front
					Text("BACK")
						.font(.muli(.bold, size: 15))
						.frame(maxWidth: .infinity, alignment: .leading)
					back
				}
				.padding()
			}
		}
	}
}

#if DEBUG
struct AddCardsViewCardCell_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.blue
				.edgesIgnoringSafeArea(.all)
			AddCardsViewCardCell(card: .init(
				parent: PREVIEW_CURRENT_STORE.user.decks.first!
			))
			.padding(.horizontal, 10)
		}
		.environmentObject(AddCardsViewModel(
			deck: PREVIEW_CURRENT_STORE.user.decks.first!,
			user: PREVIEW_CURRENT_STORE.user
		))
	}
}
#endif

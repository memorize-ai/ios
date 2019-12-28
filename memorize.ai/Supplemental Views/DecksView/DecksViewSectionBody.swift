import SwiftUI
import SwiftUIX

struct DecksViewSectionBody: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: DecksViewModel
	
	@ObservedObject var section: Deck.Section
	
	var isExpanded: Bool {
		model.isSectionExpanded(section)
	}
	
	var isOwner: Bool {
		currentStore.user.id == section.parent.creatorId
	}
	
	var body: some View {
		VStack(spacing: 8) {
			if isExpanded {
				SwitchOver(section.cardsLoadingState)
					.case(.loading) {
						ActivityIndicator(color: .gray)
					}
					.case(.success) {
						ForEach(section.cards) { card in
							DecksViewCardCell(card: card)
						}
					}
					.case(.failure) {
						Image(systemName: .exclamationmarkTriangle)
							.foregroundColor(.gray)
							.scaleEffect(1.5)
					}
			}
		}
		.padding(.top, 6)
		.animation(.linear(duration: 0.1))
	}
}

#if DEBUG
struct DecksViewSectionBody_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewSectionBody(section: .init(
			id: "0",
			parent: PREVIEW_CURRENT_STORE.user.decks.first!,
			name: "CSS",
			numberOfCards: 56,
			cards: [
				.init(
					id: "0",
					sectionId: "CSS",
					front: "This is the front of the card",
					back: "This is the back of the card",
					numberOfViews: 670,
					numberOfSkips: 40,
					userData: .init(dueDate: .now)
				),
				.init(
					id: "1",
					sectionId: "CSS",
					front: "This is the front of the second card",
					back: "This is the back of the second card",
					numberOfViews: 670,
					numberOfSkips: 40,
					userData: .init(dueDate: .now)
				)
			]
		))
		.padding(.horizontal, DecksView.horizontalPadding)
		.environmentObject(PREVIEW_CURRENT_STORE)
		.environmentObject(DecksViewModel())
	}
}
#endif

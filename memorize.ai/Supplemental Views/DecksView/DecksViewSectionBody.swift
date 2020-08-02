import SwiftUI

struct DecksViewSectionBody: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var section: Deck.Section
	
	let isSectionExpanded: (Deck.Section) -> Bool
	
	var isUnlocked: Bool {
		section.isUnlocked
	}
	
	var isExpanded: Bool {
		isSectionExpanded(section)
	}
	
	var isOwner: Bool {
		currentStore.user.id == section.parent.creatorId
	}
	
	func headerButton(text: String, color: Color) -> some View {
		CustomRectangle(
			background: Color.clear,
			borderColor: color,
			borderWidth: 1
		) {
			Text(text)
				.font(.muli(.semiBold, size: 16))
				.foregroundColor(color)
				.shrinks()
				.padding(.vertical, 4)
				.frame(maxWidth: .infinity)
		}
	}
	
	var cramButton: some View {
		CramViewNavigationLink(section: section) {
			headerButton(text: "Cram", color: .init(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)))
		}
	}
	
	var reviewButton: some View {
		ReviewViewNavigationLink(section: section) {
			headerButton(
				text: "Review \(section.numberOfDueCards?.formatted ?? "(error)")",
				color: .init(#colorLiteral(red: 0, green: 0.7647058824, blue: 0.4941176471, alpha: 1))
			)
		}
	}
	
	var body: some View {
		LazyVStack(spacing: 8) {
			if isUnlocked {
				HStack {
					if section.numberOfCards > 0 {
						cramButton
					}
					if section.isDue {
						reviewButton
					}
				}
			}
			if isExpanded {
				Group {
					switch section.cardsLoadingState {
					case .loading:
						ActivityIndicator(color: .gray)
					case .success:
						ForEach(section.cards) { card in
							DecksViewCardCell(card: card)
						}
					case .failure:
						Image(systemName: .exclamationmarkTriangle)
							.foregroundColor(.gray)
							.scaleEffect(1.5)
					default:
						EmptyView()
					}
				}
				.padding(.top, 8)
			}
		}
		.padding(.top, 6)
		.animation(.linear(duration: 0.1))
	}
}

#if DEBUG
struct DecksViewSectionBody_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewSectionBody(
			section: .init(
				id: "0",
				parent: PREVIEW_CURRENT_STORE.user.decks.first!,
				name: "CSS",
				index: 0,
				numberOfCards: 56,
				cards: [
					.init(
						id: "0",
						parent: PREVIEW_CURRENT_STORE.user.decks.first!,
						sectionId: "CSS",
						front: "This is the front of the card",
						back: "This is the back of the card",
						numberOfViews: 670,
						numberOfReviews: 0,
						numberOfSkips: 40,
						userData: .init(isNew: true, dueDate: .now)
					),
					.init(
						id: "1",
						parent: PREVIEW_CURRENT_STORE.user.decks.first!,
						sectionId: "CSS",
						front: "This is the front of the second card",
						back: "This is the back of the second card",
						numberOfViews: 670,
						numberOfReviews: 0,
						numberOfSkips: 40,
						userData: .init(isNew: false, dueDate: .now)
					)
				]
			),
			isSectionExpanded: { _ in true }
		)
		.padding(.horizontal, DecksView.horizontalPadding)
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

import SwiftUI

struct MarketDeckViewSections: View {
	static let sectionPrefix = 4
	
	@EnvironmentObject var deck: Deck
	
	@State var isExpanded = false
	
	var numberOfSections: Int {
		*deck.hasUnsectionedCards + deck.sections.count
	}
	
	var sectionPrefix: Int {
		Self.sectionPrefix - *deck.hasUnsectionedCards
	}
	
	var prefixedSections: [Deck.Section] {
		.init(deck.sections.prefix(
			isExpanded
				? MAX_NUMBER_OF_VIEWABLE_SECTIONS
				: sectionPrefix
		))
	}
	
	var content: some View {
		Group {
			if deck.hasUnsectionedCards {
				MarketDeckViewSectionRow(section: deck.unsectionedSection)
			}
			ForEach(prefixedSections, content: MarketDeckViewSectionRow.init)
			if numberOfSections > Self.sectionPrefix {
				Button(action: {
					self.isExpanded.toggle()
				}) {
					Text(
						isExpanded
							? "Show less"
							: numberOfSections > MAX_NUMBER_OF_VIEWABLE_SECTIONS
								? "Show \(MAX_NUMBER_OF_VIEWABLE_SECTIONS) sections"
								: "Show all \(numberOfSections) sections"
					)
					.font(.muli(.bold, size: 18))
					.foregroundColor(.extraPurple)
				}
				.padding(.top, 16)
			}
		}
	}
	
	var body: some View {
		VStack {
			MarketDeckViewSectionTitle("Sections")
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGray,
				borderWidth: 1.5,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				Group {
					if #available(iOS 14.0, *) {
						LazyVStack { content }
					} else {
						VStack { content }
					}
				}
				.padding(16)
			}
		}
		.padding(.horizontal, 23)
	}
}

#if DEBUG
struct MarketDeckViewSections_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewSections()
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

import SwiftUI

struct MarketDeckViewSections: View {
	static let sectionPrefix = 4
	
	@EnvironmentObject var deck: Deck
	
	@State var isExpanded = false
	
	var numberOfSections: Int {
		deck.sections.count
	}
	
	var prefixedSections: [Deck.Section] {
		isExpanded
			? deck.sections
			: .init(deck.sections.prefix(Self.sectionPrefix))
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
				VStack {
					ForEach(prefixedSections) { section in
						MarketDeckViewSectionRow(section: section)
					}
					if numberOfSections > Self.sectionPrefix {
						Button(action: {
							self.isExpanded.toggle()
						}) {
							Text(
								isExpanded
									? "SHOW LESS"
									: "SHOW ALL \(numberOfSections) SECTIONS"
							)
							.font(.muli(.bold, size: 18))
							.foregroundColor(.extraPurple)
						}
						.padding(.top, 16)
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

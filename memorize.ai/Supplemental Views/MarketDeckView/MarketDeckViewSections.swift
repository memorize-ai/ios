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
	
	func sectionRow(forSection section: Deck.Section) -> some View {
		HStack {
			Text(section.name)
				.font(.muli(.semiBold, size: 17))
			Rectangle()
				.foregroundColor(literal: #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1))
				.frame(height: 1)
			Text("(\(section.numberOfCards.formatted) card\(section.numberOfCards == 1 ? "" : "s"))")
				.font(.muli(.regular, size: 17))
				.foregroundColor(.lightGrayText)
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
				VStack {
					ForEach(prefixedSections, content: sectionRow)
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

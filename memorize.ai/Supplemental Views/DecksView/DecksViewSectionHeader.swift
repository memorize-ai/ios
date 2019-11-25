import SwiftUI

struct DecksViewSectionHeader: View {
	@ObservedObject var section: Deck.Section
	
	@Binding var isExpanded: Bool
	
	var cardCountMessage: String {
		"(\(section.numberOfCards.formatted) card\(section.numberOfCards == 1 ? "" : "s"))"
	}
	
	var minusIcon: some View {
		Capsule()
			.foregroundColor(.darkBlue)
			.frame(height: 2)
	}
	
	var plusIcon: some View {
		ZStack {
			minusIcon
			minusIcon
				.rotationEffect(.degrees(90))
		}
	}
	
	var body: some View {
		HStack(spacing: 12) {
			Text(section.name)
				.font(.muli(.bold, size: 17))
			Rectangle()
				.foregroundColor(.lightGrayBorder)
				.frame(height: 1)
			Text(cardCountMessage)
				.font(.muli(.bold, size: 15))
				.foregroundColor(.darkBlue)
			Button(action: {
				self.isExpanded.toggle()
			}) {
				ZStack {
					Circle()
						.stroke(Color.lightGrayBorder)
					Group {
						if isExpanded {
							minusIcon
						} else {
							plusIcon
						}
					}
					.padding(5)
				}
				.frame(width: 21, height: 21)
			}
		}
	}
}

#if DEBUG
struct DecksViewSectionHeader_Preview: View {
	@State var isExpanded = false
	
	var body: some View {
		DecksViewSectionHeader(
			section: .init(
				id: "0",
				name: "CSS",
				numberOfCards: 56
			),
			isExpanded: $isExpanded
		)
		.padding(.horizontal, DecksView.horizontalPadding)
	}
}

struct DecksViewSectionHeader_Previews: PreviewProvider {
	static var previews: some View {
		DecksViewSectionHeader_Preview()
	}
}
#endif

import SwiftUI

struct ReviewRecapViewCardPerformanceSection: View {
	let easyCards: [Card.ReviewData]
	let struggledCards: [Card.ReviewData]
	let forgotCards: [Card.ReviewData]
	let shouldShowDeckName: Bool
	let shouldShowSectionName: Bool
	
	var body: some View {
		VStack {
			CustomRectangle(
				background: Color.lightGrayBackground.opacity(0.5)
			) {
				Text("Card performance")
					.font(.muli(.extraBold, size: 23))
					.foregroundColor(.darkGray)
					.shrinks()
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
			}
			VStack(spacing: 12) {
				ReviewRecapViewCardPerformanceRow(
					rating: .easy,
					cards: easyCards,
					shouldShowDeckName: shouldShowDeckName,
					shouldShowSectionName: shouldShowSectionName
				)
				ReviewRecapViewCardPerformanceRow(
					rating: .struggled,
					cards: struggledCards,
					shouldShowDeckName: shouldShowDeckName,
					shouldShowSectionName: shouldShowSectionName
				)
				ReviewRecapViewCardPerformanceRow(
					rating: .forgot,
					cards: forgotCards,
					shouldShowDeckName: shouldShowDeckName,
					shouldShowSectionName: shouldShowSectionName
				)
			}
		}
	}
}

#if DEBUG
struct ReviewRecapViewCardPerformanceSection_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewCardPerformanceSection(
			easyCards: [],
			struggledCards: [],
			forgotCards: [],
			shouldShowDeckName: true,
			shouldShowSectionName: true
		)
	}
}
#endif

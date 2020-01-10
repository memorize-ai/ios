import SwiftUI

struct LearnRecapViewCardPerformance: View {
	var body: some View {
		VStack {
			Text("Card performance")
				.font(.muli(.extraBold, size: 23))
				.foregroundColor(.darkGray)
				.shrinks()
			VStack(spacing: 12) {
				ForEach([.easy, .struggled, .forgot], id: \.self) { rating in
					LearnRecapViewCardPerformanceRow(rating: rating)
				}
			}
		}
	}
}

#if DEBUG
struct LearnRecapViewCardPerformance_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewCardPerformance()
			.environmentObject(LearnViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil
			))
	}
}
#endif

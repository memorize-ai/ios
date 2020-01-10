import SwiftUI

struct LearnRecapViewSectionPerformance: View {
	var body: some View {
		VStack {
			Text("Section performance")
				.font(.muli(.extraBold, size: 23))
				.foregroundColor(.darkGray)
				.shrinks()
			VStack(spacing: 12) {
				ForEach([.easy, .struggled, .forgot], id: \.self) { rating in
					LearnRecapViewSectionPerformanceRow(rating: rating)
				}
			}
		}
	}
}

#if DEBUG
struct LearnRecapViewSectionPerformance_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewSectionPerformance()
			.environmentObject(LearnViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil
			))
	}
}
#endif

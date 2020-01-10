import SwiftUI

struct LearnRecapViewSectionPerformance: View {
	var body: some View {
		VStack {
			Text("Section performance")
				.font(.muli(.extraBold, size: 23))
				.foregroundColor(.darkGray)
				.shrinks()
			ForEach([.easy, .struggled, .forgot], id: \.self) { rating in
				LearnRecapViewSectionPerformanceRow(rating: rating)
			}
		}
	}
}

#if DEBUG
struct LearnRecapViewSectionPerformance_Previews: PreviewProvider {
	static var previews: some View {
		LearnRecapViewSectionPerformance()
	}
}
#endif

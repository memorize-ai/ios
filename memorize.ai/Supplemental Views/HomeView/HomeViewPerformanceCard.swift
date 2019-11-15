import SwiftUI

struct HomeViewPerformanceCard: View {
	var body: some View {
		CustomRectangle(
			background: Color.white,
//			borderColor: .lightGray,
//			borderWidth: 1,
			cornerRadius: 8
		) {
			VStack {
				Group {
					Text("Overall performance")
						.font(.muli(.bold, size: 20))
						.foregroundColor(.darkGray)
						.align(to: .leading)
					Rectangle()
						.frame(height: 200) // TODO: Change to actual graph
					Rectangle()
						.foregroundColor(.lightGrayBorder)
						.frame(height: 1)
						.padding(.top, 12)
						.padding(.bottom, 8)
					Text("Performance for each interest")
						.font(.muli(.bold, size: 17))
						.foregroundColor(.darkGray)
						.align(to: .leading)
				}
				.padding(.horizontal)
				HomeViewTopicPerformanceList()
			}
			.padding(.vertical)
		}
	}
}

#if DEBUG
struct HomeViewPerformanceCard_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewPerformanceCard()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

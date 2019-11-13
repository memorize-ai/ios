import SwiftUI

struct HomeViewPerformanceCard: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1,
			cornerRadius: 8
		) {
			VStack {
				Text("Overall performance")
					.font(.muli(.bold, size: 17))
					.foregroundColor(.darkGray)
					.align(to: .leading)
					.padding(.horizontal)
			}
			.padding(.vertical)
		}
	}
}

#if DEBUG
struct HomeViewPerformanceCard_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewPerformanceCard()
			.environmentObject(CurrentStore(user: .init(
				id: "0",
				name: "Ken Mueller",
				email: "kenmueller0@gmail.com",
				interests: [],
				numberOfDecks: 0
			)))
	}
}
#endif

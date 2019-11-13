import SwiftUI

struct HomeView: View {
	@Binding var isSideBarShowing: Bool
	
	var body: some View {
		ZStack(alignment: .top) {
			HomeViewTopGradient()
				.edgesIgnoringSafeArea(.all)
			VStack(spacing: 20) {
				HomeViewTopControls(
					isSideBarShowing: $isSideBarShowing
				)
				ScrollView {
					HomeViewPerformanceCard()
				}
			}
			.padding(.horizontal, 23)
		}
	}
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(isSideBarShowing: .constant(false))
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

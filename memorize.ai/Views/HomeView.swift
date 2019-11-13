import SwiftUI

struct HomeView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@Binding var isSideBarShowing: Bool
	
	var body: some View {
		VStack {
			HomeViewTopGradient()
				.edgesIgnoringSafeArea(.all)
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

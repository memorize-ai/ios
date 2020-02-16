import SwiftUI

struct HomeView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				HomeViewTopGradient(
					addedHeight: geometry.safeAreaInsets.top
				)
				.edgesIgnoringSafeArea(.all)
				VStack(spacing: 20) {
					HomeViewTopControls()
						.padding(.horizontal, 23)
					ScrollView {
						PublishDeckViewNavigationLink {
							CustomRectangle(background: Color.white) {
								HStack(spacing: 3) {
									Image(systemName: .plus)
										.font(Font.title.weight(.bold))
										.scaleEffect(0.65)
									Text("CREATE DECK")
										.font(.muli(.extraBold, size: 16))
								}
								.foregroundColor(.darkBlue)
								.padding(.leading, 12)
								.padding(.trailing)
								.padding(.vertical, 10)
							}
						}
						HomeViewMyDecksSection(
							currentUser: self.currentStore.user
						)
						.padding(.top)
						HomeViewRecommendedDecksSection()
						.padding(.top, 5)
					}
				}
			}
		}
	}
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

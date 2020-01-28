import SwiftUI

struct ReviewRecapView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				ZStack(alignment: .top) {
					Group {
						Color.lightGrayBackground
						HomeViewTopGradient(
							addedHeight: geometry.safeAreaInsets.top
						)
					}
					.edgesIgnoringSafeArea(.all)
					VStack {
						ReviewRecapViewTopControls()
							.padding(.horizontal, 23)
						ScrollView {
							VStack(spacing: 30) {
								ReviewRecapViewMainCard()
									.padding(.horizontal, 8)
							}
						}
					}
				}
			}
		}
	}
}

#if DEBUG
struct ReviewRecapView_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapView()
			.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

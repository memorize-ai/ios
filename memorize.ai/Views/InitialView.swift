import SwiftUI

struct InitialView: View {
	var body: some View {
		GeometryReader { geometry in
			NavigationView {
				ZStack {
					GeometryReader { _ in
						ZStack {
							InitialViewStackedRectangles()
								.padding(.top, -140)
							InitialViewPaginatedFeatures()
						}
						.alignment(.top)
					}
					ZStack(alignment: .bottom) {
						InitialViewBottomGradient(
							addedHeight: geometry.safeAreaInsets.bottom
						)
						InitialViewBottomButtons()
							.padding(.bottom, geometry.safeAreaInsets.bottom)
					}
					.alignment(.bottom)
				}
				.background(Color.lightGrayBackground)
				.edgesIgnoringSafeArea(.all)
			}
		}
	}
}

#if DEBUG
struct InitialView_Previews: PreviewProvider {
	static var previews: some View {
		InitialView()
	}
}
#endif

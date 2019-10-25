import SwiftUI

struct InitialView: View {
	var body: some View {
		NavigationView {
			VStack {
				GeometryReader { _ in
					ZStack {
						InitialViewStackedRectangles()
							.padding(.top, -25)
						InitialViewPaginatedFeatures()
					}
					.align(to: .top)
				}
				ZStack(alignment: .bottom) {
					InitialViewBottomGradient()
					InitialViewBottomButtons()
				}
				.align(to: .bottom)
			}
			.background(Color.lightGrayBackground)
			.edgesIgnoringSafeArea(.top)
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

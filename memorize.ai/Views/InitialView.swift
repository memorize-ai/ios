import SwiftUI

struct InitialView: View {
	var body: some View {
		NavigationView {
			ZStack {
				GeometryReader { _ in
					ZStack {
						InitialViewStackedRectangles()
							.padding(.top, -140)
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

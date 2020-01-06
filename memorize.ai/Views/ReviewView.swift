import SwiftUI

struct ReviewView: View {
	let numberOfDueCards: Int
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .top) {
				Group {
					Color.lightGrayBackground
					HomeViewTopGradient(
						addedHeight: geometry.safeAreaInsets.top
					)
				}
				.edgesIgnoringSafeArea(.all)
				VStack {
					ReviewViewTopControls()
						.padding(.horizontal, 23)
					ReviewViewCardSection()
				}
			}
		}
	}
}

#if DEBUG
struct ReviewView_Previews: PreviewProvider {
	static var previews: some View {
		ReviewView(numberOfDueCards: 5)
	}
}
#endif

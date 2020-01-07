import SwiftUI

struct ReviewView: View {
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
						.padding(.top)
					Spacer()
					Text("Tap anywhere to continue")
						.font(.muli(.bold, size: 17))
						.foregroundColor(.darkGray)
					Spacer()
				}
				.edgesIgnoringSafeArea(.bottom)
			}
		}
	}
}

#if DEBUG
struct ReviewView_Previews: PreviewProvider {
	static var previews: some View {
		ReviewView()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(ReviewViewModel(
				user: PREVIEW_CURRENT_STORE.user,
				deck: nil,
				section: nil
			))
	}
}
#endif

import SwiftUI

struct ReviewViewCardSection: View {
	var body: some View {
		VStack(spacing: 8) {
			Text("The basics") // TODO: Change this
				.font(.muli(.bold, size: 17))
				.foregroundColor(.white)
				.align(to: .leading)
				.padding(.horizontal, 14)
			GeometryReader { geometry in
				ZStack(alignment: .bottom) {
					BlankReviewViewCard(
						geometry: geometry,
						scale: 0.9,
						offset: 16
					)
					BlankReviewViewCard(
						geometry: geometry,
						scale: 0.95,
						offset: 8
					)
					ReviewViewCard(geometry: geometry) {
						Text("Content")
					}
				}
			}
		}
	}
}

#if DEBUG
struct ReviewViewCardSection_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewCardSection()
	}
}
#endif

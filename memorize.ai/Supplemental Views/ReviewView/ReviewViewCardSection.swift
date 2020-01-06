import SwiftUI

struct ReviewViewCardSection: View {
	var body: some View {
		VStack(spacing: 8) {
			Text("The basics") // TODO: Change this
				.font(.muli(.bold, size: 17))
				.foregroundColor(.white)
				.align(to: .leading)
				.padding(.horizontal, 14)
			ZStack(alignment: .bottom) {
				ReviewViewCard(scale: 0.9) {
					Text("")
				}
				.offset(y: 16)
				ReviewViewCard(scale: 0.95) {
					Text("")
				}
				.offset(y: 8)
				ReviewViewCard {
					Text("ReviewViewCard") // TODO: Change this
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

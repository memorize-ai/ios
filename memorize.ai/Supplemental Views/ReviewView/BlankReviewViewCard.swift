import SwiftUI

struct BlankReviewViewCard: View {
	let geometry: GeometryProxy
	let scale: CGFloat
	let offset: CGFloat
	
	var size: CGSize {
		geometry.size
	}
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 5)
				.foregroundColor(.white)
			RoundedRectangle(cornerRadius: 5)
				.stroke(Color.lightGray, lineWidth: 1.5)
		}
		.frame(
			width: size.width * scale,
			height: size.height * scale
		)
		.offset(y: offset)
	}
}

#if DEBUG
struct BlankReviewViewCard_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geometry in
			BlankReviewViewCard(
				geometry: geometry,
				scale: 1,
				offset: 0
			)
		}
	}
}
#endif

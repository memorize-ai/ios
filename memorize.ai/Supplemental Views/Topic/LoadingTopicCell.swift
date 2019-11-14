import SwiftUI

struct LoadingTopicCell: View {
	let dimension: CGFloat
	
	var body: some View {
		ZStack {
			Color.lightGrayBackground
			ActivityIndicator(
				color: Color.black.opacity(0.2),
				thickness: 1.5
			)
			LinearGradient(
				gradient: .init(colors: [
					Color.black.opacity(0.25),
					Color.black.opacity(0.6)
				]),
				startPoint: .top,
				endPoint: .bottom
			)
		}
		.cornerRadius(5)
		.frame(
			width: dimension,
			height: dimension
		)
	}
}

#if DEBUG
struct LoadingTopicCell_Previews: PreviewProvider {
	static var previews: some View {
		LoadingTopicCell(dimension: 109)
	}
}
#endif

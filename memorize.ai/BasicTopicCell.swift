import SwiftUI

struct BasicTopicCell: View {
	@ObservedObject var topic: Topic
	
	let dimension: CGFloat
	
	var body: some View {
		ZStack(alignment: .bottom) {
			Group {
				if topic.image == nil {
					Color.lightGrayBackground
					if topic.imageLoadingState.isLoading {
						ActivityIndicator(
							color: Color.black.opacity(0.2),
							thickness: 1.5
						)
					} else {
						Image(systemName: .exclamationmarkTriangle)
							.resizable()
							.scaleEffect(0.25)
							.foregroundColor(.darkGray)
					}
				} else {
					topic.image?
						.resizable()
						.renderingMode(.original)
						.scaledToFill()
				}
				LinearGradient(
					gradient: .init(colors: [
						Color.black.opacity(
							topic.image == nil ? 0.25 : 0.1
						),
						Color.black.opacity(0.6)
					]),
					startPoint: .top,
					endPoint: .bottom
				)
			}
			.frame(
				width: dimension,
				height: dimension
			)
			Text(topic.name)
				.font(.muli(.regular, size: 14))
				.foregroundColor(.white)
				.padding(.horizontal, 8)
				.padding(.bottom, 11)
				.lineLimit(1)
				.minimumScaleFactor(0.25)
				.frame(width: dimension)
		}
		.cornerRadius(5)
	}
}

#if DEBUG
struct BasicTopicCell_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			BasicTopicCell(
				topic: .init(
					id: "0",
					name: "Math"
				),
				dimension: 109
			)
			BasicTopicCell(
				topic: .init(
					id: "0",
					name: "Geography",
					image: .init("GeographyTopic")
				),
				dimension: 109
			)
		}
	}
}
#endif

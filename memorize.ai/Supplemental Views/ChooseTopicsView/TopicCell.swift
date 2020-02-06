import SwiftUI

struct TopicCell: View {
	static let dimension: CGFloat = 109
	
	@ObservedObject var topic: Topic
	
	let isSelected: Bool
	let toggleSelect: () -> Void
	
	var body: some View {
		Button(action: toggleSelect) {
			ZStack(alignment: .topTrailing) {
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
						width: Self.dimension,
						height: Self.dimension
					)
					Text(topic.name)
						.font(.muli(.regular, size: 14))
						.foregroundColor(.white)
						.padding(.bottom, 16)
				}
				TopicCellCheck(isSelected: isSelected)
					.padding([.trailing, .top], 8)
			}
			.cornerRadius(5)
		}
		.onAppear {
			self.topic.loadImage()
		}
	}
}

#if DEBUG
struct TopicCell_Previews: PreviewProvider {
	static var previews: some View {
		let failedTopic = Topic(
			id: "0",
			name: "Geography",
			image: .init("GeographyTopic")
		)
		failedTopic.imageLoadingState.fail(message: "Self-invoked")
		return VStack(spacing: 20) {
			TopicCell(
				topic: failedTopic,
				isSelected: false
			) {}
			TopicCell(
				topic: .init(
					id: "0",
					name: "Geography"
				),
				isSelected: true
			) {}
			TopicCell(
				topic: .init(
					id: "0",
					name: "Geography",
					image: .init("GeographyTopic")
				),
				isSelected: false
			) {}
			TopicCell(
				topic: .init(
					id: "0",
					name: "Geography"
				),
				isSelected: true
			) {}
		}
	}
}
#endif

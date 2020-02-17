import SwiftUI

struct BasicTopicCell: View {
	@ObservedObject var topic: Topic
	
	let dimension: CGFloat
	
	var body: some View {
		ZStack(alignment: .bottom) {
			Group {
				topic.image
					.resizable()
					.renderingMode(.original)
					.scaledToFill()
				LinearGradient(
					gradient: .init(colors: [
						Color.black.opacity(0.1),
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
				.shrinks()
				.frame(width: dimension)
		}
		.cornerRadius(5)
	}
}

#if DEBUG
struct BasicTopicCell_Previews: PreviewProvider {
	static var previews: some View {
		BasicTopicCell(
			topic: .init(
				id: "0",
				name: "English",
				category: .language
			),
			dimension: 109
		)
	}
}
#endif

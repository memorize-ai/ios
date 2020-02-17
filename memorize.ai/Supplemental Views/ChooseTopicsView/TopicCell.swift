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
	}
}

#if DEBUG
struct TopicCell_Previews: PreviewProvider {
	static var previews: some View {
		TopicCell(
			topic: .init(
				id: "0",
				name: "English",
				category: .language
			),
			isSelected: true
		) {}
	}
}
#endif

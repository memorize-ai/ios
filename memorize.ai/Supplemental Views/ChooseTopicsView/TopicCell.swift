import SwiftUI

struct TopicCell: View {
	static let dimension: CGFloat = 109
	
	@EnvironmentObject var currentUserStore: UserStore
	
	let topic: Topic
	
	var topicIndex: Int {
		currentUserStore.topics.firstIndex { $0 == topic } ?? 0
	}
	
	var body: some View {
		ZStack(alignment: .bottom) {
			Group {
				if topic.image == nil {
					Color.gray
					ActivityIndicator()
				} else {
					topic.image?
						.resizable()
						.scaledToFill()
				}
				LinearGradient(
					gradient: .init(colors: [
						.transparent,
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
		.cornerRadius(5)
	}
}

#if DEBUG
struct TopicCell_Previews: PreviewProvider {
	static var previews: some View {
		TopicCell(topic: .init(
			id: "0",
			name: "Geography",
			image: .init("GeographyTopic")
		))
		.environmentObject(UserStore(.init(
			id: "0",
			name: "Ken Mueller",
			email: "kenmueller0@gmail.com"
		)))
	}
}
#endif

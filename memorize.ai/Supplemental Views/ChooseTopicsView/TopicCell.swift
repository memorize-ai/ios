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
			if topic.image == nil {
				EmptyView() // TODO: Change this to skeleton
			} else {
				topic.image!
					.resizable()
					.scaledToFill()
					.frame(
						width: Self.dimension,
						height: Self.dimension
					)
			}
			Text(topic.name)
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

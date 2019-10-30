import SwiftUI

struct TopicCell: View {
	static let dimension: CGFloat = 109
	
	@EnvironmentObject var currentUserStore: UserStore
	
	let topic: Topic
	
	var topicIndex: Int {
		currentUserStore.topics.firstIndex { $0 == topic } ?? 0
	}
	
	var body: some View {
		Text(topic.name)
	}
}

#if DEBUG
struct TopicCell_Previews: PreviewProvider {
	static var previews: some View {
		TopicCell(topic: .init(
			id: "0",
			name: "Math",
			image: nil
		))
		.environmentObject(UserStore(.init(
			id: "0",
			name: "Ken Mueller",
			email: "kenmueller0@gmail.com"
		)))
	}
}
#endif

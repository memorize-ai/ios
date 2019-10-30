import SwiftUI

struct TopicCell: View {
	@ObservedObject topicStore: TopicStore
	
	let topic: Topic
	
	var topicIndex: Int {
		topicStore.topics.firstIndex { $0 == topic } ?? 0
	}
	
	var body: some View {
		Text("TopicCell")
	}
}

#if DEBUG
struct TopicCell_Previews: PreviewProvider {
	static var previews: some View {
		TopicCell(topicStore: .init, topic: <#T##Topic#>)
	}
}
#endif

import SwiftUI

struct TopicPerformanceSheetView: View {
	@ObservedObject var topic: Topic
	
	var body: some View {
		Text(topic.name)
	}
}

#if DEBUG
struct TopicPerformanceSheetView_Previews: PreviewProvider {
	static var previews: some View {
		TopicPerformanceSheetView(topic: .init(
			id: "0",
			name: "Geography",
			image: .init("GeographyTopic"),
			topDecks: []
		))
	}
}
#endif

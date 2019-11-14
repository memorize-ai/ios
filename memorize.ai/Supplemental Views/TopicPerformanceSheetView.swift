import SwiftUI

struct TopicPerformanceSheetView: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var topic: Topic
	
	var body: some View {
		HStack {
			Text(topic.name)
			XButton(.purple, height: 20)
		}
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
		.environmentObject(PREVIEW_CURRENT_STORE)
	}
}
#endif

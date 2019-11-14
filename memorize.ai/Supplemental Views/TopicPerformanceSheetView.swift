import SwiftUI

struct TopicPerformanceSheetView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var topic: Topic
	
	var xButton: some View {
		Button(action: {
			self.presentationMode.wrappedValue.dismiss()
		}) {
			XButton(.purple, height: 20)
		}
	}
	
	var body: some View {
		HStack {
			Text(topic.name)
			xButton
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

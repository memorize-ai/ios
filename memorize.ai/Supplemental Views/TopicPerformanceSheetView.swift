import SwiftUI

struct TopicPerformanceSheetView: View {
	@Environment(\.presentationMode) var presentationMode
	
	@EnvironmentObject var currentStore: CurrentStore
	
	@ObservedObject var topic: Topic
	
	var xButton: some View {
		Button(action: {
			self.presentationMode.wrappedValue.dismiss()
		}) {
			XButton(.purple, height: 16)
		}
	}
	
	var body: some View {
		VStack {
			ZStack {
				Color.lightGrayBackground
				HStack {
					Text(topic.name)
						.font(.muli(.bold, size: 20))
						.foregroundColor(.darkGray)
					Spacer()
					xButton
				}
				.padding(.horizontal, 25)
			}
			.frame(height: 64)
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

import SwiftUI

struct ChooseTopicsViewContent: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var model: ChooseTopicsViewModel
	
	var body: some View {
		VStack {
			if currentStore.topicsLoadingState.isLoading {
				ActivityIndicator(color: .white)
				Spacer()
			} else {
				ScrollView(showsIndicators: false) {
					TopicGrid(
						width: SCREEN_SIZE.width - 32,
						topics: currentStore.topics,
						isSelected: { self.model.isTopicSelected($0) },
						toggleSelect: model.toggleTopicSelect
					)
					.padding(.vertical, TopicGrid.spacing)
					.padding(.bottom)
				}
			}
		}
		.onAppear {
			self.currentStore.loadAllTopics()
		}
	}
}

#if DEBUG
struct ChooseTopicsViewContent_Previews: PreviewProvider {
	static var previews: some View {
		ChooseTopicsViewContent()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(ChooseTopicsViewModel(
				currentUser: .init(
					id: "0",
					name: "Ken Mueller",
					email: "kenmueller0@gmail.com",
					interests: [],
					numberOfDecks: 0,
					xp: 0
				)
			))
	}
}
#endif

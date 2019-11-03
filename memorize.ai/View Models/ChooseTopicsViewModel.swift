import Combine

final class ChooseTopicsViewModel: ViewModel {
	let currentUser: User
	
	@Published var selectedTopics = [String]()
	
	init(currentUser: User) {
		self.currentUser = currentUser
	}
	
	func isTopicSelected(_ topic: Topic) -> Bool {
		selectedTopics.contains(topic.id)
	}
	
	func toggleTopicSelect(_ topic: Topic) {
		let topicId = topic.id
		if isTopicSelected(topic) {
			selectedTopics.removeAll { $0 == topicId }
			currentUser.removeInterest(topicId: topicId)
		} else {
			selectedTopics.append(topicId)
			currentUser.addInterest(topicId: topicId)
		}
	}
}

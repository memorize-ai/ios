import Combine

final class TopicStore: ObservableObject {
	@Published var topics = [Topic]()
}

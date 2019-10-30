import Combine

final class UserStore: ObservableObject {
	@Published var user: User
	@Published var topics: [Topic]
	
	init(_ user: User, topics: [Topic] = []) {
		self.user = user
		self.topics = topics
	}
}

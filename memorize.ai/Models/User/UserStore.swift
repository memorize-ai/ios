import Combine

final class UserStore: ObservableObject {
	@Published var user: User
	
	@Published var topics: [Topic]
	@Published var topicsLoadingState = LoadingState.none
	
	init(_ user: User, topics: [Topic] = []) {
		self.user = user
		self.topics = topics
	}
	
	func loadTopics() {
		topicsLoadingState = .loading()
		firestore.collection("topics").addSnapshotListener().done { snapshot in
			snapshot.documentChanges.forEach { change in
				let document = change.document
				let topicId = document.documentID
				switch change.type {
				case .added:
					self.topics.append(
						Topic(
							id: topicId,
							name: document.get("name") as? String ?? "Unknown"
						).load()
					)
				case .modified:
					self.topics.first { $0.id == topicId }?
						.updateFromSnapshot(document)
				case .removed:
					self.topics = self.topics.filter { $0.id != topicId }
				}
			}
			self.topicsLoadingState = .success()
		}.catch { error in
			self.topicsLoadingState = .failure(
				message: error.localizedDescription
			)
		}
	}
}

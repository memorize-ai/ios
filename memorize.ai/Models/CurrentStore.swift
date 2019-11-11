import Combine
import FirebaseFirestore
import PromiseKit
import LoadingState

final class CurrentStore: ObservableObject {
	@Published var user: User
	
	@Published var topics: [Topic]
	@Published var topicsLoadingState = LoadingState()
	
	init(user: User, topics: [Topic] = []) {
		self.user = user
		self.topics = topics
	}
	
	func loadTopics() {
		topicsLoadingState.startLoading()
		firestore.collection("topics").addSnapshotListener { snapshot, error in
			guard error == nil, let documentChanges = snapshot?.documentChanges else {
				self.topicsLoadingState.fail(error: error ?? UNKNOWN_ERROR)
				return
			}
			for change in documentChanges {
				let document = change.document
				let topicId = document.documentID
				switch change.type {
				case .added:
					self.topics.append(Topic(
						id: topicId,
						name: document.get("name") as? String ?? "Unknown",
						topDecks: document.get("topDecks") as? [String] ?? []
					).loadImage())
				case .modified:
					self.topics.first { $0.id == topicId }?
						.updateFromSnapshot(document)
				case .removed:
					self.topics.removeAll { $0.id == topicId }
				}
			}
			self.topics.sort(by: \.name)
			self.topicsLoadingState.succeed()
		}
	}
}

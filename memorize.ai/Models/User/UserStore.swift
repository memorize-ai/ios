import Combine
import FirebaseFirestore
import PromiseKit

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
		firestore.collection("topics").addSnapshotListener { snapshot, error in
			guard error == nil, let documentChanges = snapshot?.documentChanges else {
				return self.topicsLoadingState = .failure(
					message: (error ?? UNKNOWN_ERROR).localizedDescription
				)
			}
			documentChanges.forEach { change in
				let document = change.document
				let topicId = document.documentID
				switch change.type {
				case .added:
					self.topics.append(
						Topic(
							id: topicId,
							name: document.get("name") as? String ?? "Unknown"
						) { isSelected in
							self.onTopicSelect(
								id: topicId,
								isSelected: isSelected
							)
						}.load()
					)
				case .modified:
					self.topics.first { $0.id == topicId }?
						.updateFromSnapshot(document)
				case .removed:
					self.topics.removeAll { $0.id == topicId }
				}
			}
			self.topicsLoadingState = .success()
		}
	}
	
	@discardableResult
	func onTopicSelect(id topicId: String, isSelected: Bool) -> Promise<Void> {
		firestore.document("users/\(user.id)").updateData([
			"topics": isSelected
				? FieldValue.arrayUnion([topicId])
				: FieldValue.arrayRemove([topicId])
		])
	}
}

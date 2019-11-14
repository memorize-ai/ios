import SwiftUI
import FirebaseFirestore
import PromiseKit
import LoadingState

final class Topic: ObservableObject, Identifiable, Equatable, Hashable {
	static var cache = [String: Topic]()
	
	let id: String
	
	@Published var name: String
	@Published var image: Image?
	@Published var topDecks: [String]
	
	@Published var imageLoadingState = LoadingState()
	
	init(
		id: String,
		name: String,
		image: Image? = nil,
		topDecks: [String]
	) {
		self.id = id
		self.name = name
		self.image = image
		self.topDecks = topDecks
	}
	
	convenience init(snapshot: DocumentSnapshot) {
		self.init(
			id: snapshot.documentID,
			name: snapshot.get("name") as? String ?? "Unknown",
			topDecks: snapshot.get("topDecks") as? [String] ?? []
		)
	}
	
	@discardableResult
	func loadImage() -> Self {
		guard imageLoadingState.isNone else { return self }
		imageLoadingState.startLoading()
		storage.child("topics/\(id)").getData().done { data in
			guard let image = Image(data: data) else {
				self.imageLoadingState.fail(message: "Malformed data")
				return
			}
			self.image = image
			self.imageLoadingState.succeed()
		}.catch { error in
			self.imageLoadingState.fail(error: error)
		}
		return self
	}
	
	@discardableResult
	func updateFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		name = snapshot.get("name") as? String ?? name
		topDecks = snapshot.get("topDecks") as? [String] ?? topDecks
		return self
	}
	
	static func fromId(_ id: String) -> Promise<Topic> {
		var didFulfill = false
		var topic: Topic?
		return .init { seal in
			if let cachedTopic = cache[id] {
				return seal.fulfill(cachedTopic)
			}
			firestore.document("topics/\(id)").addSnapshotListener { snapshot, error in
				guard error == nil, let snapshot = snapshot else {
					return seal.reject(error ?? UNKNOWN_ERROR)
				}
				if didFulfill {
					topic?.updateFromSnapshot(snapshot)
				} else {
					didFulfill = true
					topic = .init(snapshot: snapshot)
					seal.fulfill(topic!.cache())
				}
			}
		}
	}
	
	@discardableResult
	func cache() -> Self {
		Self.cache[id] = self
		return self
	}
	
	static func == (lhs: Topic, rhs: Topic) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

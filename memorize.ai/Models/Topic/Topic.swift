import SwiftUI
import FirebaseFirestore
import LoadingState

final class Topic: ObservableObject, Identifiable, Equatable, Hashable {
	let id: String
	
	@Published var name: String
	@Published var image: Image?
	@Published var topDecks: [String]
	
	@Published var loadingState = LoadingState()
	
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
	
	@discardableResult
	func loadImage() -> Self {
		loadingState.startLoading()
		storage.child("topics/\(id)").getData().done { data in
			guard let image = Image(data: data) else {
				self.loadingState.fail(message: "Malformed data")
				return
			}
			self.image = image
			self.loadingState.succeed()
		}.catch { error in
			self.loadingState.fail(error: error)
		}
		return self
	}
	
	@discardableResult
	func updateFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		name = snapshot.get("name") as? String ?? name
		topDecks = snapshot.get("topDecks") as? [String] ?? topDecks
		return self
	}
	
	static func == (lhs: Topic, rhs: Topic) -> Bool {
		lhs.id == rhs.id
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

import SwiftUI
import FirebaseFirestore

final class Topic: ObservableObject, Identifiable, Equatable, Hashable {
	let id: String
	
	@Published var name: String
	@Published var image: Image?
	@Published var topDecks: [String]
	
	@Published var loadingState = LoadingState.none
	
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
	func load() -> Self {
		loadingState = .loading
		storage.child("topics/\(id)").getData().done { data in
			guard let image = Image(data: data) else {
				return self.loadingState = .failure(
					message: "Malformed data"
				)
			}
			self.image = image
			self.loadingState = .success
		}.catch { error in
			self.loadingState = .failure(
				message: error.localizedDescription
			)
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

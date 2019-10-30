import SwiftUI
import FirebaseFirestore

final class Topic: Identifiable, Equatable {
	let id: String
	let willChange: () -> Void
	
	var name: String { willSet { willChange() } }
	var image: Image? { willSet { willChange() } }
	
	var loadingState = LoadingState.none { willSet { willChange() } }
	
	init(
		id: String,
		willChange: @escaping () -> Void,
		name: String,
		image: Image? = nil
	) {
		self.id = id
		self.willChange = willChange
		self.name = name
		self.image = image
	}
	
	@discardableResult
	func load() -> Self {
		loadingState = .loading()
		storage.child("topics/\(id)").getData().done { data in
			guard let image = Image(data: data) else {
				return self.loadingState = .failure(
					message: "Malformed data"
				)
			}
			self.image = image
			self.loadingState = .success()
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
		return self
	}
	
	static func == (lhs: Topic, rhs: Topic) -> Bool {
		lhs.id == rhs.id
	}
}

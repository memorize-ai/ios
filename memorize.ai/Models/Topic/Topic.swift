import SwiftUI
import FirebaseFirestore

final class Topic: ObservableObject, Identifiable, Equatable {
	let id: String
	
	@Published var name: String
	@Published var image: Image?
	
	@Published var loadingState = LoadingState.none
	
	@Published var isSelected: Bool {
		didSet {
			onSelect?(isSelected)
		}
	}
	
	let onSelect: ((Bool) -> Void)?
	
	init(
		id: String,
		name: String,
		image: Image? = nil,
		isSelected: Bool = false,
		onSelect: ((Bool) -> Void)? = nil
	) {
		self.id = id
		self.name = name
		self.image = image
		self.isSelected = isSelected
		self.onSelect = onSelect
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

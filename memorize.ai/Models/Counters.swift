import Combine

final class Counters: ObservableObject {
	enum Key: String {
		case decks
	}
	
	static let shared = Counters()
	
	private(set) var values = [Key: Int]()
	
	subscript(key: Key) -> Int? {
		values[key]
	}
	
	@discardableResult
	func observe(_ key: Key) -> Self {
		guard values[key] == nil else { return self }
		
		firestore.document("counters/\(key.rawValue)").addSnapshotListener { snapshot, error in
			guard error == nil, let snapshot = snapshot else { return }
			self.values[key] = snapshot.get("value") as? Int
		}
			
		return self
	}
}

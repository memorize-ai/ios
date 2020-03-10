import Combine
import FirebaseFirestore

final class Counters: ObservableObject {
	enum Key: String {
		case decks
		
		var document: DocumentReference {
			firestore.document("counters/\(rawValue)")
		}
	}
	
	static let shared = Counters()
	
	@Published private(set) var values = [Key: Int]()
	
	subscript(key: Key) -> Int? {
		values[key]
	}
	
	@discardableResult
	func get(_ key: Key) -> Self {
		guard values[key] == nil else { return self }
		
		onBackgroundThread {
			key.document.getDocument()
				.done { snapshot in
					onMainThread {
						self.values[key] = snapshot.get("value") as? Int
					}
				}
				.cauterize()
		}
		
		return self
	}
	
	@discardableResult
	func observe(_ key: Key) -> Self {
		guard values[key] == nil else { return self }
		
		onBackgroundThread {
			key.document.addSnapshotListener { snapshot, error in
				guard error == nil, let snapshot = snapshot else { return }
				onMainThread {
					self.values[key] = snapshot.get("value") as? Int
				}
			}
		}
			
		return self
	}
}

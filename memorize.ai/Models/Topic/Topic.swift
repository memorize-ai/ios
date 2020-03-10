import SwiftUI
import FirebaseFirestore
import PromiseKit
import LoadingState

final class Topic: ObservableObject, Identifiable, Equatable, Hashable {
	enum Category: String {
		case language
		case code
		case science
		case math
		case art
		case prep
		case politics
	}
	
	static var cache = [String: Topic]()
	
	let id: String
	
	@Published var name: String
	@Published var category: Category
	@Published var image: Image
	
	init(id: String, name: String, category: Category) {
		self.id = id
		self.name = name
		self.category = category
		
		if let imageFromName = UIImage(named: name) {
			image = .init(uiImage: imageFromName)
		} else {
			image = .init({
				switch category {
				case .language:
					return "Language"
				case .code:
					return "Code"
				case .science:
					return "Science"
				case .math:
					return "Math"
				case .art:
					return "Literature"
				case .prep:
					return "Competition Prep"
				case .politics:
					return "Politics"
				}
			}())
		}
	}
	
	convenience init(snapshot: DocumentSnapshot) {
		self.init(
			id: snapshot.documentID,
			name: snapshot.get("name") as? String ?? "Unknown",
			category: {
				guard let category = snapshot.get("category") as? String else {
					return .language
				}
				return Category(rawValue: category) ?? .language
			}()
		)
	}
	
	@discardableResult
	func updateFromSnapshot(_ snapshot: DocumentSnapshot) -> Self {
		name = snapshot.get("name") as? String ?? name
		category = {
			guard let categoryString = snapshot.get("category") as? String else {
				return category
			}
			return Category(rawValue: categoryString) ?? category
		}()
		return self
	}
	
	static func fromId(_ id: String) -> Promise<Topic> {
		var didFulfill = false
		var topic: Topic?
		return .init { seal in
			if let cachedTopic = cache[id] {
				return seal.fulfill(cachedTopic)
			}
			onBackgroundThread {
				firestore.document("topics/\(id)").addSnapshotListener { snapshot, error in
					guard error == nil, let snapshot = snapshot else {
						return seal.reject(error ?? UNKNOWN_ERROR)
					}
					if didFulfill {
						onMainThread {
							topic?.updateFromSnapshot(snapshot)
						}
					} else {
						didFulfill = true
						topic = .init(snapshot: snapshot)
						onMainThread {
							seal.fulfill(topic!.cache())
						}
					}
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

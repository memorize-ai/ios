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
			}() as String)
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
	
	static func fromId(_ id: String) -> Promise<Topic> {
		.init { seal in
			if let cachedTopic = cache[id] {
				return seal.fulfill(cachedTopic)
			}
			
			firestore.document("topics/\(id)").getDocument()
				.done { snapshot in
					seal.fulfill(Topic(snapshot: snapshot).cache())
				}
				.catch(seal.reject)
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

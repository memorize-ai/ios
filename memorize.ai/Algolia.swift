import InstantSearchClient

class Algolia {
	static let client = Client(appID: "35UFDKN0J5", apiKey: "81d7ac9db3332e01c684c982e0bc3f02")
	static let indices: [AlgoliaIndex : Index] = [
		.decks: client.index(withName: "decks"),
		.users: client.index(withName: "users"),
		.uploads: client.index(withName: "uploads")
	]
	
	static func search(_ index: AlgoliaIndex, for query: String, completion: @escaping ([[String : Any]], Error?) -> Void) -> Operation? {
		return indices[index]?.search(Query(query: query)) { content, error in
			completion(content?["hits"] as? [[String : Any]] ?? [], error)
		}
	}
}

enum AlgoliaIndex {
	case decks
	case users
	case uploads
}

import InstantSearchClient

class Algolia {
	static let client = Client(appID: "35UFDKN0J5", apiKey: "81d7ac9db3332e01c684c982e0bc3f02")
	static let indices: [AlgoliaIndex : Index] = [
		.decks: client.index(withName: "decks"),
		.users: client.index(withName: "users")
	]
	
	static func search(_ index: AlgoliaIndex, for query: String, completion: @escaping ([[String : Any]], Error?) -> Void) {
		indices[index]?.search(Query(query: query)) { content, error in
			guard error == nil, let hits = content?["hits"] as? [[String : Any]] else { return completion([], error) }
			completion(hits, nil)
		}
	}
}

enum AlgoliaIndex {
	case decks
	case users
}

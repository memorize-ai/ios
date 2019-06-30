import InstantSearchClient

class Algolia {
	typealias SearchResult = [String : Any]
	
	static let client = Client(appID: "35UFDKN0J5", apiKey: "81d7ac9db3332e01c684c982e0bc3f02")
	static let indices: [AlgoliaIndex : Index] = [
		.decks: client.index(withName: "decks"),
		.users: client.index(withName: "users"),
		.uploads: client.index(withName: "uploads")
	]
	
	@discardableResult
	static func search(_ index: AlgoliaIndex, for query: String, completion: @escaping ([SearchResult], Error?) -> Void) -> Operation? {
		return indices[index]?.search(Query(query: query)) { content, error in
			completion(content?["hits"] as? [SearchResult] ?? [], error)
		}
	}
	
	static func id(result: SearchResult) -> String? {
		return result["objectID"] as? String
	}
}

enum AlgoliaIndex {
	case decks
	case users
	case uploads
}

import Alamofire
import PromiseKit

extension Deck {
	static func search(
		query: String,
		filterForTopics topicsFilter: [Topic]?,
		averageRatingGreaterThan ratingFilter: Double?,
		numberOfDownloadsGreaterThan downloadsFilter: Int?
	) -> Promise<[Deck]> {
		var filters = [String: Any]()
		
		if let topicsFilter = topicsFilter {
			filters["topics"] = topicsFilter.map(~\.id)
		}
		if let ratingFilter = ratingFilter {
			filters["average_rating"] = ["from": ratingFilter]
		}
		if let downloadsFilter = downloadsFilter {
			filters["download_count"] = ["from": downloadsFilter]
		}
		
		return .init { seal in
			AF.request(
				"\(APP_SEARCH_API_ENDPOINT)/api/as/v1/engines/\(DECKS_ENGINE_NAME)/search",
				method: .get,
				parameters: [
					"query": query,
					"filters": filters
				],
				headers: [
					.init(name: "Content-Type", value: "application/json"),
					.init(name: "Authorization", value: "Bearer \(DECKS_SEARCH_KEY)")
				]
			).responseJSON { response in
				switch response.result {
				case let .success(json):
					guard let json = json as? [String: Any] else {
						return seal.reject(UNKNOWN_ERROR)
					}
					seal.fulfill(translateSearchResponseJSON(json))
				case let .failure(error):
					seal.reject(error)
				}
			}
		}
	}
	
	private static func translateSearchResponseJSON(_ json: [String: Any]) -> [Deck] {
		print("JSON_RESPONSE:", json)
		return []
	}
}

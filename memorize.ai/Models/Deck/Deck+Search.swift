import Alamofire
import PromiseKit

extension Deck {
	static func search(
		query: String,
		filterForTopics topicsFilter: [Topic]?,
		averageRatingGreaterThan ratingFilter: Double?,
		numberOfDownloadsGreaterThan downloadsFilter: Int?
	) -> Promise<[Deck]> {
		.init { seal in
			AF.request(
				"\(APP_SEARCH_API_ENDPOINT)/api/as/v1/engines/\(DECKS_ENGINE_NAME)/search",
				method: .post,
				headers: [
					HTTPHeader(name: "Content-Type", value: "application/json"),
					HTTPHeader(name: "Authorization", value: "Bearer \(DECKS_SEARCH_KEY)")
				]
			).responseJSON { response in
				switch response.result {
				case let .success(json):
					seal.fulfill(translateSearchResponseJSON(json))
				case let .failure(error):
					seal.reject(error)
				}
			}
		}
	}
	
	private static func translateSearchResponseJSON(_ json: Any) -> [Deck] {
		
	}
}

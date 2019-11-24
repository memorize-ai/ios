import SwiftUI
import Alamofire
import PromiseKit

extension Deck {
	convenience init(searchResultJSON json: [String: [String: Any]]) {
		self.init(
			id: json["id"]?["raw"] as? String ?? "0",
			topics: json["topics"]?["raw"] as? [String] ?? [],
			hasImage: json["has_image"]?["raw"] as? Bool ?? false,
			name: json["name"]?["raw"] as? String ?? "Unknown",
			subtitle: json["subtitle"]?["raw"] as? String ?? "(none)",
			numberOfViews: json["view_count"]?["raw"] as? Int ?? 0,
			numberOfUniqueViews: json["unique_view_count"]?["raw"] as? Int ?? 0,
			numberOfRatings: json["rating_count"]?["raw"] as? Int ?? 0,
			averageRating: json["average_rating"]?["raw"] as? Double ?? 0,
			numberOfDownloads: json["download_count"]?["raw"] as? Int ?? 0,
			dateCreated: (json["created"]?["raw"] as? String)?.toDate() ?? .init(),
			dateLastUpdated: (json["updated"]?["raw"] as? String)?.toDate() ?? .init()
		)
	}
	
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
		(json["results"] as? [[String: [String: Any]]] ?? []).map(Deck.init)
	}
}
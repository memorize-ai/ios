import SwiftUI
import Alamofire
import PromiseKit

extension Deck {
	enum SortAlgorithm {
		case relevance
		case recommended
		case top
		case new
		case recentlyUpdated
		
		var jsonEncoded: [String: String]? {
			switch self {
			case .relevance:
				return nil
			case .recommended, .top:
				return ["score": "desc"]
			case .new:
				return ["created": "desc"]
			case .recentlyUpdated:
				return ["updated": "desc"]
			}
		}
	}
	
	convenience init(searchResultJSON json: [String: [String: Any]]) {
		self.init(
			id: json["id"]?["raw"] as? String ?? "0",
			topics: json["topics"]?["raw"] as? [String] ?? [],
			hasImage: json["has_image"]?["raw"] as? Bool ?? false,
			name: json["name"]?["raw"] as? String ?? "Unknown",
			subtitle: json["subtitle"]?["raw"] as? String ?? "(error)",
			description: json["description"]?["raw"] as? String ?? "(error)",
			numberOfViews: json["view_count"]?["raw"] as? Int ?? 0,
			numberOfUniqueViews: json["unique_view_count"]?["raw"] as? Int ?? 0,
			numberOfRatings: json["rating_count"]?["raw"] as? Int ?? 0,
			numberOf1StarRatings: json["one_star_rating_count"]?["raw"] as? Int ?? 0,
			numberOf2StarRatings: json["two_star_rating_count"]?["raw"] as? Int ?? 0,
			numberOf3StarRatings: json["three_star_rating_count"]?["raw"] as? Int ?? 0,
			numberOf4StarRatings: json["four_star_rating_count"]?["raw"] as? Int ?? 0,
			numberOf5StarRatings: json["five_star_rating_count"]?["raw"] as? Int ?? 0,
			averageRating: json["average_rating"]?["raw"] as? Double ?? 0,
			numberOfDownloads: json["download_count"]?["raw"] as? Int ?? 0,
			numberOfCards: json["card_count"]?["raw"] as? Int ?? 0,
			numberOfUnsectionedCards: json["unsectioned_card_count"]?["raw"] as? Int ?? 0,
			numberOfCurrentUsers: json["current_user_count"]?["raw"] as? Int ?? 0,
			numberOfAllTimeUsers: json["all_time_user_count"]?["raw"] as? Int ?? 0,
			numberOfFavorites: json["favorite_count"]?["raw"] as? Int ?? 0,
			creatorId: json["creator_id"]?["raw"] as? String ?? "0",
			dateCreated: (json["created"]?["raw"] as? String)?.toDate() ?? .now,
			dateLastUpdated: (json["updated"]?["raw"] as? String)?.toDate() ?? .now,
			snapshotListener: nil
		)
	}
	
	static func search(
		query: String = "",
		filterForTopics topicsFilter: [String]? = nil,
		averageRatingGreaterThan ratingFilter: Double? = nil,
		numberOfDownloadsGreaterThan downloadsFilter: Int? = nil,
		sortBy sortAlgorithm: SortAlgorithm = .relevance
	) -> Promise<[Deck]> {
		var filters = [String: Any]()
		if let topicsFilter = topicsFilter {
			filters["topics"] = topicsFilter
		}
		if let ratingFilter = ratingFilter {
			filters["average_rating"] = ["from": ratingFilter]
		}
		if let downloadsFilter = downloadsFilter {
			filters["download_count"] = ["from": downloadsFilter]
		}
		
		var parameters = ["query": query as Any]
		if !filters.isEmpty {
			parameters["filters"] = filters
		}
		if let sort = sortAlgorithm.jsonEncoded {
			parameters["sort"] = sort
		}
		
		return .init { seal in
			AF.request(
				"\(APP_SEARCH_API_ENDPOINT)/api/as/v1/engines/\(DECKS_ENGINE_NAME)/search",
				parameters: parameters,
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
	
	static func recommendedDecks(forUser user: User) -> Promise<[Deck]> {
		search(
			filterForTopics: user.interests.isEmpty ? nil : user.interests,
			sortBy: .recommended
		)
	}
}

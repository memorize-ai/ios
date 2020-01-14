import Foundation
import Combine
import LoadingState

extension Card {
	final class ReviewData: ObservableObject, Identifiable, Equatable, Hashable {
		struct Prediction {
			let easy: Date
			let struggled: Date
			let forgot: Date
			
			init(functionResponse response: [String: Int]) {
				func dateForKey(_ key: String) -> Date {
					response[key].map {
						.init(timeIntervalSince1970: .init($0) / 1000)
					} ?? .now
				}
				
				easy = dateForKey("0")
				struggled = dateForKey("1")
				forgot = dateForKey("2")
			}
		}
		
		let parent: Card
		
		@Published var prediction: Prediction?
		@Published var predictionLoadingState = LoadingState()
		
		@Published var isNewlyMastered: Bool?
		
		init(parent: Card) {
			self.parent = parent
		}
		
		func loadPrediction() -> Self {
			guard predictionLoadingState.isNone else { return self }
			
			predictionLoadingState.startLoading()
			
			functions.httpsCallable("getCardPrediction").call(data: [
				"deck": parent.parent.id,
				"card": parent.id
			]).done { result in
				guard let data = result.data as? [String: Int] else {
					self.predictionLoadingState.fail(message: "Malformed response")
					return
				}
				self.prediction = .init(functionResponse: data)
				self.predictionLoadingState.succeed()
			}.catch { error in
				self.predictionLoadingState.fail(error: error)
			}
			
			return self
		}
		
		func predictionForRating(_ rating: PerformanceRating) -> Date? {
			switch rating {
			case .easy:
				return prediction?.easy
			case .struggled:
				return prediction?.struggled
			case .forgot:
				return prediction?.forgot
			}
		}
		
		func predictionMessageForRating(_ rating: PerformanceRating) -> String? {
			guard let dueDate = predictionForRating(rating) else { return nil }
			return "+\(Date().compare(against: dueDate).split(separator: " ").dropFirst().joined(separator: " "))"
		}
		
		static func == (lhs: ReviewData, rhs: ReviewData) -> Bool {
			lhs.parent == rhs.parent
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(parent)
		}
	}
}

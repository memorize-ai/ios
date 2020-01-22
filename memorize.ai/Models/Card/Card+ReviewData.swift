import Foundation
import Combine
import LoadingState

extension Card {
	final class ReviewData: ObservableObject, Identifiable, Equatable, Hashable {
		static let NUMBER_OF_CONSECUTIVE_CORRECT_ATTEMPTS_FOR_MASTERED = 6
		
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
		let userData: UserData?
		
		@Published var prediction: Prediction?
		@Published var predictionLoadingState = LoadingState()
		
		@Published var streak: Int
		@Published var isNewlyMastered: Bool?
		
		init(parent: Card, userData: UserData?) {
			self.parent = parent
			self.userData = userData
			
			streak = userData?.streak ?? 0
		}
		
		var isNew: Bool {
			userData == nil
		}
		
		func updateStreakForRating(_ rating: PerformanceRating) {
			streak = rating.isCorrect ? streak + 1 : 0
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
			predictionForRating(rating).map { dueDate in
				"+\(Date().comparisonMessage(against: dueDate))"
			}
		}
		
		static func == (lhs: ReviewData, rhs: ReviewData) -> Bool {
			lhs.parent == rhs.parent
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(parent)
		}
	}
}

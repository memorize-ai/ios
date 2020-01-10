import Foundation
import Combine
import LoadingState

extension Card {
	final class ReviewData: ObservableObject, Identifiable, Equatable, Hashable {
		struct Prediction {
			let easy: Date
			let struggled: Date
			let forgot: Date
			
			init(functionResponse response: [Int: Date]) {
				easy = response[0] ?? .now
				struggled = response[1] ?? .now
				forgot = response[2] ?? .now
			}
		}
		
		let parent: Card
		
		@Published var prediction: Prediction?
		@Published var predictionLoadingState = LoadingState()
		
		init(parent: Card) {
			self.parent = parent
		}
		
		func loadPrediction() {
			guard predictionLoadingState.isNone else { return }
			predictionLoadingState.startLoading()
			functions.httpsCallable("getCardPrediction").call(data: [
				"deck": parent.parent.id,
				"card": parent.id
			]).done { result in
				guard let data = result.data as? [Int: Date] else {
					self.predictionLoadingState.fail(message: "Malformed response")
					return
				}
				self.prediction = .init(functionResponse: data)
				self.predictionLoadingState.succeed()
			}.catch { error in
				self.predictionLoadingState.fail(error: error)
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

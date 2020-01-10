import Foundation
import Combine
import LoadingState

extension Card {
	final class ReviewData: ObservableObject, Identifiable, Equatable, Hashable {
		struct Prediction {
			let easy: Date
			let struggled: Date
			let forgot: Date
			
//			init(functionResponse: )
		}
		
		let parent: Card
		
		@Published var prediction: Prediction?
		@Published var predictionLoadingState = LoadingState()
		
		init(parent: Card) {
			self.parent = parent
		}
		
		func loadPrediction() {
			// TODO: Load prediction
		}
		
		static func == (lhs: ReviewData, rhs: ReviewData) -> Bool {
			lhs.parent == rhs.parent
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(parent)
		}
	}
}

extension Card {
	final class LearnData {
		static let NUMBER_OF_CONSECUTIVE_EASY_ATTEMPTS_FOR_MASTERED = 5
		
		let parent: Card
		var ratings: [Card.PerformanceRating]
		
		init(parent: Card, ratings: [Card.PerformanceRating] = []) {
			self.parent = parent
			self.ratings = ratings
		}
		
		var isMastered: Bool {
			var acc = 0
			
			for rating in ratings {
				if rating == .easy {
					acc++
				} else {
					break
				}
			}
			
			return acc >= Self.NUMBER_OF_CONSECUTIVE_EASY_ATTEMPTS_FOR_MASTERED
		}
		
		@discardableResult
		func addRating(_ rating: Card.PerformanceRating) -> Self {
			ratings.insert(rating, at: 0)
			return self
		}
	}
}

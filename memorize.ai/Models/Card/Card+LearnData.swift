extension Card {
	final class LearnData {
		final class Attempt {
			let rating: Card.PerformanceRating
			
			init(rating: Card.PerformanceRating) {
				self.rating = rating
			}
		}
		
		static let NUMBER_OF_EASY_ATTEMPTS_FOR_MASTERED = 20
		
		var attempts = [Attempt]()
		
		var isMastered: Bool {
			attempts.reduce(0) { acc, attempt in
				acc + *(attempt.rating == .easy)
			} >= Self.NUMBER_OF_EASY_ATTEMPTS_FOR_MASTERED
		}
	}
}

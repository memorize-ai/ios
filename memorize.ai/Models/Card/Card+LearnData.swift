import Combine

extension Card {
	final class LearnData: ObservableObject, Identifiable, Equatable, Hashable {
		static let NUMBER_OF_CONSECUTIVE_EASY_ATTEMPTS_FOR_MASTERED = 5
		
		let parent: Card
		
		@Published var ratings: [PerformanceRating]
		
		init(parent: Card, ratings: [PerformanceRating] = []) {
			self.parent = parent
			self.ratings = ratings
		}
		
		var streak: Int {
			var acc = 0
			
			for rating in ratings {
				if rating == .easy {
					acc++
				} else {
					break
				}
			}
			
			return acc
		}
		
		var isMastered: Bool {
			streak >= Self.NUMBER_OF_CONSECUTIVE_EASY_ATTEMPTS_FOR_MASTERED
		}
		
		@discardableResult
		func addRating(_ rating: PerformanceRating) -> Self {
			ratings.insert(rating, at: 0)
			return self
		}
		
		static func == (lhs: LearnData, rhs: LearnData) -> Bool {
			lhs.parent == rhs.parent &&
			lhs.ratings == rhs.ratings
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(parent)
		}
	}
}

import Combine

extension Card {
	final class LearnData: ObservableObject, Identifiable, Equatable, Hashable {
		static let NUMBER_OF_CONSECUTIVE_EASY_ATTEMPTS_FOR_MASTERED = 3
		
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
		
		var mostFrequentRating: PerformanceRating? {
			var acc = [PerformanceRating: Int]()
			
			for rating in ratings {
				acc[rating] = (acc[rating] ?? 0) + 1
			}
			
			return acc.max { $0.value < $1.value }?.key
		}
		
		func countOfRating(_ rating: PerformanceRating) -> Int {
			ratings.filter { $0 == rating }.count
		}
		
		@discardableResult
		func addRating(_ rating: PerformanceRating) -> Bool {
			ratings.insert(rating, at: 0)
			return rating == .easy
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

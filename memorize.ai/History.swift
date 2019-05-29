import Foundation

class History {
	let id: String
	let date: Date
	let next: Date
	let correct: Bool
	let elapsed: Int
	
	init(id: String, date: Date, next: Date, correct: Bool, elapsed: Int) {
		self.id = id
		self.date = date
		self.next = next
		self.correct = correct
		self.elapsed = elapsed
	}
}

import Foundation

class History {
	let id: String
	let date: Date
	let next: Date
	let rating: Int
	let elapsed: Int
	
	init(id: String, date: Date, next: Date, rating: Int, elapsed: Int) {
		self.id = id
		self.date = date
		self.next = next
		self.rating = rating
		self.elapsed = elapsed
	}
}

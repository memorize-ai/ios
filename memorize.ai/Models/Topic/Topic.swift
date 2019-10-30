import SwiftUI

struct Topic: Identifiable, Equatable {
	let id: String
	var name: String
	var image: Image?
	
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}
}

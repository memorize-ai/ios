import Foundation

extension String {
	var trimmed: String {
		trimmingCharacters(in: .whitespaces)
	}
	
	var isTrimmedEmpty: Bool {
		trimmed.isEmpty
	}
	
	func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter.date(from: self)
	}
}

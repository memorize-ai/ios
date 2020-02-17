import Foundation

extension String {
	var trimmed: Self {
		trimmingCharacters(in: .whitespaces)
	}
	
	var isTrimmedEmpty: Bool {
		trimmed.isEmpty
	}
	
	var nilIfEmpty: Self? {
		isEmpty ? nil : self
	}
	
	func defaultIfEmpty(_ default: String) -> String {
		isEmpty ? `default` : self
	}
	
	func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter.date(from: self)
	}
}

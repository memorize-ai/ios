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
	
	func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZ") -> Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter.date(from: self)
	}
	
	func match(_ regex: String) -> [[String]] {
		let nsString = self as NSString
		return (try? NSRegularExpression(pattern: regex, options: []))?
			.matches(in: self, options: [], range: NSMakeRange(0, count)).map { match in
				(0..<match.numberOfRanges).map {
					match.range(at: $0).location == NSNotFound
						? ""
						: nsString.substring(with: match.range(at: $0))
				}
			} ?? []
	}
}

import Foundation

extension Date {
	static var now: Self { .init() }
	
	private static var distanceFormatter: DateComponentsFormatter {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.zeroFormattingBehavior = .dropAll
		formatter.maximumUnitCount = 1
		formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
		return formatter
	}
	
	func comparisonMessage(against otherDate: Date = .now, equalsError: TimeInterval = 1) -> String {
		if abs(timeIntervalSince(otherDate)) < equalsError {
			return "now"
		}
		
		let ceiling = Date(timeIntervalSince1970: ceil(otherDate.timeIntervalSince1970))
		
		return (
			self < otherDate
				? Self.distanceFormatter.string(from: self, to: ceiling)
				: Self.distanceFormatter.string(from: ceiling, to: self)
		) ?? "(error)"
	}
	
	func compare(against otherDate: Date = .now, equalsError: TimeInterval = 1) -> String {
		self < otherDate
			? "in \(comparisonMessage(against: otherDate, equalsError: equalsError))"
			: "\(comparisonMessage(against: otherDate, equalsError: equalsError)) ago"
	}
	
	func format(with format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
	
	var formatted: String {
		format(with: "MMM d, yyyy @ h:mm a")
	}
	
	var formattedCompact: String {
		format(with: "MMM d, yyyy")
	}
}

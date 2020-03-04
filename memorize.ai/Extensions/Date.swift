import Foundation

extension Date {
	static let SECONDS_IN_HOUR: TimeInterval = 60 * 60
	static let SECONDS_IN_DAY: TimeInterval = SECONDS_IN_HOUR * 24
	
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
		let difference = otherDate.timeIntervalSince(self)
		
		if abs(difference) < equalsError {
			return "now"
		}
		
		let otherDate = abs(difference) < Self.SECONDS_IN_DAY - Self.SECONDS_IN_HOUR
			? otherDate
			: addingTimeInterval(
				round(difference, toClosestMultipleOf: Self.SECONDS_IN_DAY)
			)
		
		return (
			self < otherDate
				? Self.distanceFormatter.string(from: self, to: otherDate)
				: Self.distanceFormatter.string(from: otherDate, to: self)
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

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
	
	func compare(against otherDate: Date = .now) -> String {
		self == otherDate
			? "now"
			: self < otherDate
				? "in \(Self.distanceFormatter.string(from: self, to: otherDate) ?? "(error)")"
				: "\(Self.distanceFormatter.string(from: otherDate, to: self) ?? "(error)") ago"
	}
	
	var formatted: String {
		description // TODO: Add custom formatting
	}
}

import Foundation

extension Double {
	var formatted: String {
		let logResult = log10(abs(self))
		let decimalResult =
			(self / pow(10, floor(logResult))).oneDecimalPlace
		let formattedDecimalResult = decimalResult.isInt
			? String(Int(decimalResult))
			: String(decimalResult)
		switch true {
		case logResult < 3:
			return .init(self)
		case logResult < 6:
			return "\(formattedDecimalResult)k"
		case logResult < 9:
			return "\(formattedDecimalResult)m"
		case logResult < 12:
			return "\(formattedDecimalResult)b"
		default:
			return "overflow"
		}
	}
	
	var oneDecimalPlace: Double {
		(self * 10).rounded() / 10
	}
	
	var isInt: Bool {
		self == floor(self)
	}
}

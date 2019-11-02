import Foundation

let UNKNOWN_ERROR = UnknownError.default

enum UnknownError: LocalizedError {
	case `default`
	
	var localizedDescription: String {
		"Unknown error"
	}
}

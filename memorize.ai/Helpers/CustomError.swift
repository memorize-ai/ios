import Foundation

struct CustomError: LocalizedError {
	let message: String
	
	var localizedDescription: String { message }
	var errorDescription: String? { message }
}

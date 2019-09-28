import Foundation

enum LoadingState {
	case `default`
	case loading(date: Date = Date())
	case success(date: Date = Date())
	case failure(date: Date = Date(), message: String)
}

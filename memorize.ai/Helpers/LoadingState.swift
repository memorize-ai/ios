import Foundation

enum LoadingState {
	case `default`
	case loading(date: Date = .init())
	case success(date: Date = .init())
	case failure(date: Date = .init(), message: String)
}

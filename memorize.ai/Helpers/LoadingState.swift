import Foundation

enum LoadingState {
	case `default`
	case loading(date: Date = .init())
	case success(date: Date = .init())
	case failure(date: Date = .init(), message: String)
	
	var isLoading: Bool {
		switch self {
		case .loading(date: _):
			return true
		default:
			return false
		}
	}
	
	var didSucceed: Bool {
		switch self {
		case .success(date: _):
			return true
		default:
			return false
		}
	}
	
	var didFail: Bool {
		switch self {
		case .failure(date: _, message: _):
			return true
		default:
			return false
		}
	}
}

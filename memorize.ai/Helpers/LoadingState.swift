import Foundation

enum LoadingState {
	case none
	case loading(date: Date = .init())
	case success(date: Date = .init())
	case failure(date: Date = .init(), message: String)
	
	var isNone: Bool {
		get {
			switch self {
			case .none:
				return true
			default:
				return false
			}
		}
		set {
			guard newValue else { return }
			self = .none
		}
	}
	
	var isLoading: Bool {
		get {
			switch self {
			case .loading(date: _):
				return true
			default:
				return false
			}
		}
		set {
			self = newValue ? .loading() : .none
		}
	}
	
	var didSucceed: Bool {
		get {
			switch self {
			case .success(date: _):
				return true
			default:
				return false
			}
		}
		set {
			self = newValue ? .success() : .none
		}
	}
	
	var didFail: Bool {
		get {
			switch self {
			case .failure(date: _, message: _):
				return true
			default:
				return false
			}
		}
		set {
			self = newValue ? .failure(message: "Unknown") : .none
		}
	}
}

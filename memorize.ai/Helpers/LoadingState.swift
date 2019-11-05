import Foundation

enum LoadingState: Equatable {
	case none
	case loading(date: Date = .init())
	case success(date: Date = .init())
	case failure(date: Date = .init(), message: String)
	
	var isNone: Bool {
		get {
			self == .none
		}
		set {
			guard newValue else { return }
			self = .none
		}
	}
	
	var isLoading: Bool {
		get {
			if case .loading(date: _) = self {
				return true
			} else {
				return false
			}
		}
		set {
			self = newValue ? .loading() : .none
		}
	}
	
	var didSucceed: Bool {
		get {
			if case .success(date: _) = self {
				return true
			} else {
				return false
			}
		}
		set {
			self = newValue ? .success() : .none
		}
	}
	
	var didFail: Bool {
		get {
			if case .failure(date: _, message: _) = self {
				return true
			} else {
				return false
			}
		}
		set {
			self = newValue ? .failure(message: "Unknown") : .none
		}
	}
	
	var failureMessage: String? {
		if case .failure(date: _, message: let message) = self {
			return message
		}
		return nil
	}
}

import StoreKit

class StoreReview {
	private static let SESSION_COUNT_KEY = "sessionCount"
	
	static var sessionCount: Int {
		get {
			defaults.integer(forKey: SESSION_COUNT_KEY)
		}
		set {
			defaults.set(newValue, forKey: SESSION_COUNT_KEY)
		}
	}
	
	static func onStartup() {
		sessionCount++
		
		switch sessionCount {
		case 10, 50:
			requestReview()
		case _ where sessionCount % 100 == 0:
			requestReview()
		default:
			break
		}
	}
	
	static func requestReview() {
		SKStoreReviewController.requestReview()
	}
}

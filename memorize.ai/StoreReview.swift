import StoreKit

class StoreReview {
	static var sessionCount: Int {
		get {
			return defaults.integer(forKey: "sessionCount")
		}
		set {
			defaults.set(newValue, forKey: "sessionCount")
		}
	}
	
	static func onStartup() {
		sessionCount += 1
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

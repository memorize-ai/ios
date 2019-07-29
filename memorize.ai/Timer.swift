import Foundation

class Time {
	static let shared = Time()
	
	var milliseconds: Int
	
	init(_ milliseconds: Int = 0) {
		self.milliseconds = milliseconds
	}
	
	private var timer: Timer?
	
	func start() {
		timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
			self.milliseconds += 1
		}
	}
	
	@discardableResult
	func stop() -> Int {
		timer?.invalidate()
		return milliseconds
	}
	
	func reset() {
		stop()
		milliseconds = 0
	}
}

import UIKit

var keyboardOffset: CGFloat = 0

class KeyboardHandler {
	private static var listeners = [UIViewController : (KeyboardDirection) -> Void]()
	
	static func addListener(_ viewController: UIViewController, listener: @escaping (KeyboardDirection) -> Void) {
		listeners[viewController] = listener
	}
	
	static func addListener(_ viewController: UIViewController, up: @escaping () -> Void, down: @escaping () -> Void) {
		listeners[viewController] = {
			$0.call(up: up, down: down)
		}
	}
	
	static func removeListener(_ viewController: UIViewController) {
		NotificationCenter.default.removeObserver(viewController, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(viewController, name: UIResponder.keyboardWillHideNotification, object: nil)
		listeners.removeValue(forKey: viewController)
	}
	
	static func call(_ direction: KeyboardDirection) {
		listeners.forEach {
			$1(direction)
		}
	}
}

enum KeyboardDirection {
	case up
	case down
	
	func call(up: () -> Void, down: () -> Void) {
		switch self {
		case .up:
			up()
		case .down:
			down()
		}
	}
}
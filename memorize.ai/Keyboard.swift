import UIKit

var currentViewController: UIViewController?

extension UIViewController {
	func updateCurrentViewController(stopAudio: Bool = true) {
		currentViewController = self
		if stopAudio {
			Audio.stop()
		}
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@objc
	private func keyboardWillShow(notification: NSNotification) {
		guard let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
		keyboardOffset = height
		ChangeHandler.call(.keyboardMoved)
		KeyboardHandler.call(.up)
	}
	
	@objc
	private func keyboardWillHide(notification: NSNotification) {
		keyboardOffset = 0
		ChangeHandler.call(.keyboardMoved)
		KeyboardHandler.call(.down)
	}
}

extension UITextField {
	func setKeyboard(_ type: UIKeyboardAppearance) {
		keyboardAppearance = type
	}
	
	func setKeyboard() {
		setKeyboard(getKeyboardAppearance())
	}
}

extension UITextView {
	func setKeyboard(_ type: KeyboardType) {
		keyboardAppearance = getKeyboardAppearance()
		let toolbar = UIToolbar()
		toolbar.sizeToFit()
		toolbar.barStyle = isDarkMode() ? .blackTranslucent : .default
		toolbar.setItems(items(type).map {
			if isDarkMode() {
				$0.tintColor = .white
			}
			return $0
		}, animated: false)
		inputAccessoryView = toolbar
	}
	
	func add(_ text: String) {
		insertText(text)
	}
	
	func add(_ text: String, shift: Int) {
		add(text)
		self.shift(shift)
	}
	
	func shift(_ times: Int = 1) {
		guard let selectedRange = selectedTextRange, let newPosition = position(from: selectedRange.start, offset: -times) else { return }
		selectedTextRange = textRange(from: newPosition, to: newPosition)
	}
	
	private func items(_ type: KeyboardType) -> [UIBarButtonItem] {
		let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
		var items = [UIBarButtonItem]()
		switch type {
		case .plain:
			items = []
		case .advanced:
			items = [
				UIBarButtonItem(title: "Code", style: .plain, target: self, action: #selector(code)),
				flex,
				UIBarButtonItem(title: "Math", style: .plain, target: self, action: #selector(math)),
				flex,
				UIBarButtonItem(title: "#", style: .plain, target: self, action: #selector(markdownHeader)),
				flex,
				UIBarButtonItem(title: "**", style: .plain, target: self, action: #selector(markdownBold)),
				flex,
				UIBarButtonItem(title: "\\", style: .plain, target: self, action: #selector(backSlash)),
				flex,
				UIBarButtonItem(title: "{ }", style: .plain, target: self, action: #selector(curlyBraces))
			]
		}
		return items + [flex, UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))]
	}
	
	@objc
	private func done() {
		currentViewController?.view.endEditing(false)
	}
	
	@objc
	private func code() {
		add("```\n\n```", shift: 5)
	}
	
	@objc
	private func math() {
		add("\\(\\)", shift: 2)
	}
	
	@objc
	private func markdownHeader() {
		add("#")
	}
	
	@objc
	private func markdownBold() {
		add("****", shift: 2)
	}
	
	@objc
	private func backSlash() {
		add("\\")
	}
	
	@objc
	private func curlyBraces() {
		add("{}", shift: 1)
	}
}

enum KeyboardType {
	case plain
	case advanced
}

fileprivate func isDarkMode() -> Bool {
	return Setting.get(.darkMode)?.data as? Bool ?? false
}

fileprivate func getKeyboardAppearance() -> UIKeyboardAppearance {
	return isDarkMode() ? .dark : .default
}

import UIKit

extension UITextView {
	func setKeyboard(_ type: KeyboardType) {
		let toolbar = UIToolbar()
		toolbar.sizeToFit()
		toolbar.barStyle = Setting.get(.darkMode)?.data as? Bool ?? false ? .blackTranslucent : .default
		toolbar.setItems(items(type), animated: false)
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
	
	@objc private func done() {
		currentViewController?.view.endEditing(false)
	}
	
	@objc private func code() {
		add("```\n\n```", shift: 5)
	}
	
	@objc private func math() {
		add("\\(\\)", shift: 2)
	}
	
	@objc private func markdownHeader() {
		add("#")
	}
	
	@objc private func markdownBold() {
		add("****", shift: 2)
	}
	
	@objc private func backSlash() {
		add("\\")
	}
	
	@objc private func curlyBraces() {
		add("{}", shift: 1)
	}
}

enum KeyboardType {
	case plain
	case advanced
}

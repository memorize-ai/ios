import HTML

extension Card {
	private static let css = """
	
	""" // TODO: Add CSS
	
	private static func htmlWithText(_ text: String) -> HTMLElement {
		HTMLElement.html
			.child {
				HTMLElement.head
					.child {
						HTMLElement.style
							.child(css)
					}
			}
			.child {
				HTMLElement.body
					.child(text)
			}
	}
	
	func renderFront() -> String {
		HTML.render {
			Self.htmlWithText(front)
		}
	}
	
	func renderBack() -> String {
		HTML.render {
			Self.htmlWithText(back)
		}
	}
	
	func renderSide(_ side: Side) -> String {
		switch side {
		case .front:
			return renderFront()
		case .back:
			return renderBack()
		}
	}
}

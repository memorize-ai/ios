import HTML

extension Card {
	private static let css = """
	body > :not(ul):not(ol) {
		margin: 0 40px 40px 40px;
	}
	body > ul, ol {
		margin-top: 0;
		margin-left: 80px;
		margin-right: 40px;
	}
	img {
		border-radius: 32px;
		width: calc(100% - 80px);
	}
	"""
	
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
					.paddingTop("36px")
					.fontFamily("Helvetica")
					.fontSize("45px")
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

import HTML

fileprivate let DEFAULT_FONT_SIZE = 45

extension Card {
	private static func htmlWithText(
		_ text: String,
		withFontSize fontSize: Int = DEFAULT_FONT_SIZE
	) -> HTMLElement {
		HTMLElement.html
			.child {
				HTMLElement.head
					.child {
						HTMLElement.meta
							.name("viewport")
							.content("width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1")
					}
					.child {
						HTMLElement.link
							.rel("stylesheet")
							.href("froala.css")
					}
					.child {
						HTMLElement.link
							.rel("stylesheet")
							.href("katex.css")
					}
					.child {
						HTMLElement.script
							.defer()
							.src("katex.js")
					}
					.child {
						HTMLElement.script
							.defer()
							.src("auto-render.js")
							.onLoad("renderMathInElement(document.body)")
					}
			}
			.child {
				HTMLElement.body
					.class("fr-view")
					.fontFamily("sans-serif")
					.fontSize("\(fontSize)px")
					.margin("20px 30px")
					.child(text)
			}
	}
	
	func renderFront(withFontSize fontSize: Int = DEFAULT_FONT_SIZE) -> String {
		HTML.render {
			Self.htmlWithText(front, withFontSize: fontSize)
		}
	}
	
	func renderBack(withFontSize fontSize: Int = DEFAULT_FONT_SIZE) -> String {
		HTML.render {
			Self.htmlWithText(back, withFontSize: fontSize)
		}
	}
	
	func renderSide(_ side: Side, withFontSize fontSize: Int = DEFAULT_FONT_SIZE) -> String {
		switch side {
		case .front:
			return renderFront(withFontSize: fontSize)
		case .back:
			return renderBack(withFontSize: fontSize)
		}
	}
}

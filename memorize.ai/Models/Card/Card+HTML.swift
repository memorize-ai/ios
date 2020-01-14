import HTML

extension Card {
	private static func htmlWithText(_ text: String) -> HTMLElement {
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
					.fontSize("45px")
					.margin("20px 30px")
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

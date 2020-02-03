import HTML

extension Card {
	private static let displayCss = """
	@font-face {
		font-family: Muli;
		src: url('Muli-Regular.ttf') format('truetype');
	}
	body {
		font-family: Muli, sans-serif;
	}
	"""
	
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
							.href("ckeditor.css")
					}
					.child {
						HTMLElement.link
							.rel("stylesheet")
							.href("katex.css")
					}
					.child {
						HTMLElement.link
							.rel("stylesheet")
							.href("prism.css")
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
					.child {
						HTMLElement.script
							.defer()
							.src("prism.js")
					}
					.child {
						HTMLElement.style
							.child(displayCss)
					}
			}
			.child {
				HTMLElement.body
					.class("ck-content")
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

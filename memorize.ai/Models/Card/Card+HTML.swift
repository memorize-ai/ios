import HTML

extension Card {
	private static let css = #"""
	body {
		padding-top: 36px;
		font-family: sans-serif;
		font-size: 45px;
	}
	.fr-text-gray {
		color: #aaa;
	}
	.fr-text-bordered {
		border-top: solid 1px #222;
		border-bottom: solid 1px #222;
		padding: 10px 0;
	}
	.fr-text-spaced {
		letter-spacing: 1px;
	}
	.fr-text-uppercase {
		text-transform: uppercase;
	}
	.fr-class-highlighted {
		background-color: #ff0;
	}
	.fr-class-code {
		border-color: #ccc;
		border-radius: 2px;
		-moz-border-radius: 2px;
		-webkit-border-radius: 2px;
		-moz-background-clip: padding;
		-webkit-background-clip: padding-box;
		background-clip: padding-box;
		background: #f5f5f5;
		padding: 10px;
		font-family: 'Courier New', Courier, monospace;
	}
	.fr-class-transparency {
		opacity: 0.5;
	}
	"""#
	
	private static func htmlWithText(_ text: String) -> HTMLElement {
		HTMLElement.html
			.child {
				HTMLElement.head
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

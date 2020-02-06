import WebView
import HTML

extension Card {
	private static let displayCss = """
	@font-face {
		font-family: Muli;
		src: url('Muli-Regular.ttf') format('truetype');
	}
	body {
		font-family: Muli, Arial, Helvetica, sans-serif;
		margin-left: 12px;
		margin-right: 12px;
	}
	:focus {
		outline: none;
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
					.child(removeAudioUrls(fromText: text))
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
	
	func render(side: Side) -> String {
		switch side {
		case .front:
			return renderFront()
		case .back:
			return renderBack()
		}
	}
	
	func webView(forSide side: Side) -> WebView {
		WebView(html: render(side: side), baseURL: WEB_VIEW_BASE_URL)
	}
}

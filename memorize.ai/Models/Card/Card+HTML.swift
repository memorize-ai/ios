import WebView
import HTML
import Audio

extension Card {
	private static func htmlWithText(_ text: String) -> HTMLElement {
		HTMLElement.html
			.child {
				HTMLElement.head
					.child(VIEWPORT_META_TAG)
					.child {
						HTMLElement.link
							.rel("stylesheet")
							.href("display/index.css")
					}
					.child {
						HTMLElement.script
							.defer()
							.src("display/index.js")
							.onLoad("renderMathInElement(document.body)")
					}
			}
			.child {
				HTMLElement.body
					.class("ck-content")
					.child(Audio.removeAudioTags(inHTML: text))
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
		.init(html: render(side: side), baseURL: WEB_VIEW_BASE_URL)
	}
}

import SwiftUI
import WebView
import WebKit
import HTML

struct FroalaEditor: View {
	final class Coordinator: NSObject, WKScriptMessageHandler {
		@Binding var html: String
		
		init(html: Binding<String>) {
			_html = html
		}
		
		func userContentController(
			_ userContentController: WKUserContentController,
			didReceive message: WKScriptMessage
		) {
			guard let html = message.body as? String else { return }
			self.html = html
		}
	}
	
	@Binding var html: String
	
	let configuration: WKWebViewConfiguration
	
	init(html: Binding<String>) {
		_html = html
		
		let userContentController = WKUserContentController()
		userContentController.add(Coordinator(html: html), name: "main")
		
		let configuration = WKWebViewConfiguration()
		configuration.userContentController = userContentController
		
		self.configuration = configuration
	}
	
	var body: some View {
		WebView(
			html: HTML.render {
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
								HTMLElement.script
									.src("froala.js")
							}
							.child {
								HTMLElement.style
								.child("""
								#editor :focus {
									outline: none;
								}
								#editor .fr-toolbar,
								#editor .fr-wrapper {
									border: none;
								}
								#editor .second-toolbar {
									visibility: hidden;
								}
								""")
							}
					}
					.child {
						HTMLElement.body
							.child {
								HTMLElement.div
									.id("editor")
									.child(html)
							}
							.child {
								HTMLElement.script
									.child("""
									new FroalaEditor('#editor', {
										events: {
											input: ({ target: { innerHTML: html } }) =>
												webkit.messageHandlers.main.postMessage(html)
										}
									})
									""")
							}
					}
			},
			baseURL: .init(fileURLWithPath: Bundle.main.bundlePath, isDirectory: true),
			configuration: configuration
		)
	}
}

#if DEBUG
struct FroalaEditor_Previews: PreviewProvider {
	static var previews: some View {
		FroalaEditor(html: .constant(""))
	}
}
#endif

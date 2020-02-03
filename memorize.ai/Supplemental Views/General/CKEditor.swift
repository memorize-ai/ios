import SwiftUI
import WebView
import WebKit
import HTML

struct CKEditor: View {
	final class Coordinator: NSObject, WKScriptMessageHandler {
		@Binding var html: String
		
		init(html: Binding<String>) {
			_html = html
		}
		
		func userContentController(
			_ userContentController: WKUserContentController,
			didReceive message: WKScriptMessage
		) {
			switch message.name {
			case "data":
				guard let html = message.body as? String else { return }
				self.html = html
			case "error":
				guard let error = message.body as? String else { return }
				showAlert(
					title: "An error occurred in the editor",
					message: error
				)
			default:
				break
			}
		}
	}
	
	@Binding var html: String
	
	let height: CGFloat?
	let configuration: WKWebViewConfiguration
	
	init(html: Binding<String>, height: CGFloat? = 300) {
		_html = html
		self.height = height
		
		let coordinator = Coordinator(html: html)
		let userContentController = WKUserContentController()
		
		userContentController.add(coordinator, name: "data")
		userContentController.add(coordinator, name: "error")
		
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
								HTMLElement.script
									.src("ckeditor.js")
							}
							.child {
								HTMLElement.style
									.child(#"""
									@font-face {
										font-family: Muli;
										src: url(Muli-Regular.ttf) format(truetype);
									}
									body {
										font-family: Muli, sans-serif;
										margin: 0;
									}
									"""#)
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
									.child(#"""
									ClassicEditor
										.create(document.getElementById('editor'), {
											autosave: {
												save: editor =>
													webkit.messageHandlers.data.postMessage(editor.getData())
											}
										})
										.catch(error =>
											webkit.messageHandlers.error.postMessage(error.toString())
										)
									"""#)
							}
					}
			},
			baseURL: WEB_VIEW_BASE_URL,
			configuration: configuration
		)
		.frame(height: height)
	}
}

#if DEBUG
struct CKEditor_Previews: PreviewProvider {
	static var previews: some View {
		CKEditor(html: .constant(""))
	}
}
#endif

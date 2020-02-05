import SwiftUI
import WebKit
import HTML

struct CKEditor: View {
	private static let css = """
	@font-face {
		font-family: Muli;
		src: url('Muli-Regular.ttf') format('truetype');
	}
	body {
		font-family: Muli, sans-serif;
		margin: 0;
	}
	.ck.ck-dropdown__panel.ck-dropdown__panel_sw > .ck.ck-toolbar > .ck.ck-toolbar__items {
		width: calc(100vw - 10px * 2);
		flex-wrap: wrap;
	}
	.ck.ck-editor__main > .ck-editor__editable {
		height: calc(100vh - 40.2px);
	}
	"""
	
	struct Representable: UIViewControllerRepresentable {
		final class Container: UIViewController, WKScriptMessageHandler {
			@Binding var html: String
			
			let deckId: String
			let width: CGFloat
			let height: CGFloat
						
			init(html: Binding<String>, deckId: String, width: CGFloat, height: CGFloat) {
				_html = html
				
				self.deckId = deckId
				self.width = width
				self.height = height
				
				super.init(nibName: nil, bundle: nil)
			}
			
			required init?(coder: NSCoder) {
				fatalError("init(coder:) has not been implemented")
			}
			
			override func viewDidLoad() {
				super.viewDidLoad()
				
				view.frame = .init(x: 0, y: 0, width: width, height: height)
				
				let userContentController = WKUserContentController()
				
				userContentController.add(self, name: "data")
				userContentController.add(self, name: "error")
				
				let configuration = WKWebViewConfiguration()
				configuration.userContentController = userContentController
				
				let webView = WKWebView(frame: view.frame, configuration: configuration)
				
				webView.loadHTML(baseURL: WEB_VIEW_BASE_URL) {
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
										.child(css)
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
										ClassicEditor
											.create(document.getElementById('editor'), {
												simpleUpload: {
													uploadUrl: '\(WEB_URL)/_api/upload-deck-asset?deck=\(deckId)&type={type}'
												},
												autosave: {
													save: editor =>
														webkit.messageHandlers.data.postMessage(editor.getData())
												}
											})
											.then(editor =>
												editor.ui.focusTracker.on('change:isFocused', (event, name, isFocused) =>
													isFocused
														? setTimeout(() => scrollTo(0, 0), 150)
														: null
												)
											)
											.catch(error =>
												webkit.messageHandlers.error.postMessage(error.toString())
											)
										""")
								}
						}
				}
				
				view.addSubview(webView)
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
		
		let deckId: String
		let width: CGFloat
		let height: CGFloat
		
		func makeUIViewController(context: Context) -> Container {
			.init(html: $html, deckId: deckId, width: width, height: height)
		}
		
		func updateUIViewController(_ uiViewController: Container, context: Context) {}
	}
	
	@Binding var html: String
	
	let deckId: String
	let width: CGFloat
	let height: CGFloat
	
	init(html: Binding<String>, deckId: String, width: CGFloat, height: CGFloat = 300) {
		_html = html
		
		self.deckId = deckId
		self.width = width
		self.height = height
	}
	
	var body: some View {
		Representable(html: $html, deckId: deckId, width: width, height: height)
			.frame(width: width, height: height)
	}
}

#if DEBUG
struct CKEditor_Previews: PreviewProvider {
	static var previews: some View {
		CKEditor(
			html: .constant(""),
			deckId: "0",
			width: SCREEN_SIZE.width - 20 * 2
		)
	}
}
#endif

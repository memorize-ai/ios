import SwiftUI
import WebKit
import HTML

struct CKEditor: View {
	@EnvironmentObject var currentStore: CurrentStore
	
	struct Representable: UIViewControllerRepresentable {
		final class Container: UIViewController, WKScriptMessageHandler {
			@Binding var html: String
			@Binding var isFocused: Bool
			
			let uid: String
			let deckId: String
			let width: CGFloat
			let height: CGFloat
			
			var webView: WKWebView?
			
			init(
				html: Binding<String>,
				isFocused: Binding<Bool>,
				uid: String,
				deckId: String,
				width: CGFloat,
				height: CGFloat
			) {
				_html = html
				_isFocused = isFocused
				
				self.uid = uid
				self.deckId = deckId
				self.width = width
				self.height = height
				
				super.init(nibName: nil, bundle: nil)
			}
			
			required init?(coder: NSCoder) {
				fatalError("init(coder:) has not been implemented")
			}
			
			var uploadUrl: String {
				"\(WEB_URL)/_api/upload-deck-asset?user=\(uid)&deck=\(deckId)"
			}
			
			override func viewDidLoad() {
				super.viewDidLoad()
				
				view.frame = .init(x: 0, y: 0, width: width, height: height)
				
				let userContentController = WKUserContentController()
				
				userContentController.add(self, name: "data")
				userContentController.add(self, name: "focus")
				userContentController.add(self, name: "error")
				
				let configuration = WKWebViewConfiguration()
				configuration.userContentController = userContentController
				
				let webView = WKWebView(frame: view.frame, configuration: configuration)
				self.webView = webView
				
				webView.loadHTML(baseURL: WEB_VIEW_BASE_URL) {
					HTMLElement.html
						.child {
							HTMLElement.head
								.child(VIEWPORT_META_TAG)
								.child {
									HTMLElement.link
										.rel("stylesheet")
										.href("editor/index.css")
								}
								.child {
									HTMLElement.script
										.src("editor/index.js")
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
										.child("ClassicEditor.create(document.getElementById('editor'),{simpleUpload:{uploadUrl:'\(uploadUrl)'},autosave:{save:e=>webkit.messageHandlers.data.postMessage(e.getData())}}).then(e=>e.ui.focusTracker.on('change:isFocused',(e,s,a)=>{if(a)setTimeout(()=>scrollTo(0,0),150);webkit.messageHandlers.focus.postMessage(a)})).catch(e=>webkit.messageHandlers.error.postMessage(e.toString()))")
									// swiftlint:disable:previous line_length
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
				case "focus":
					guard let isFocused = message.body as? Bool else { return }
					self.isFocused = isFocused
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
		@Binding var isFocused: Bool
		
		let uid: String
		let deckId: String
		let width: CGFloat
		let height: CGFloat
		
		func makeUIViewController(context: Context) -> Container {
			.init(
				html: $html,
				isFocused: $isFocused,
				uid: uid,
				deckId: deckId,
				width: width,
				height: height
			)
		}
		
		func updateUIViewController(_ container: Container, context: Context) {
			let frame = CGRect(x: 0, y: 0, width: width, height: height)
			
			container.view.frame = frame
			container.webView?.frame = frame
		}
	}
	
	@Binding var html: String
	@Binding var isFocused: Bool
	
	let deckId: String
	let width: CGFloat
	let height: CGFloat
	
	init(html: Binding<String>, isFocused: Binding<Bool>, deckId: String, width: CGFloat, height: CGFloat = 300) {
		_html = html
		_isFocused = isFocused
		
		self.deckId = deckId
		self.width = width
		self.height = height
	}
	
	var body: some View {
		Representable(
			html: $html,
			isFocused: $isFocused,
			uid: currentStore.user.id,
			deckId: deckId,
			width: width,
			height: height
		)
		.frame(width: width, height: height)
	}
}

#if DEBUG
struct CKEditor_Previews: PreviewProvider {
	static var previews: some View {
		CKEditor(
			html: .constant(""),
			isFocused: .constant(false),
			deckId: "0",
			width: SCREEN_SIZE.width - 20 * 2
		)
	}
}
#endif

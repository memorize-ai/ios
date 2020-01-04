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
								#editor #math-1 > img {
									padding-top: 4px;
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
									const execCommand = (command, payload = null) =>
										document.execCommand(command, false, payload)
									
									const moveCursor = characters => {
										const selection = getSelection()
										
										if (selection.rangeCount > 0) {
											const textNode = selection.focusNode
											const newOffset = selection.focusOffset + characters
											selection.collapse(textNode, Math.min(textNode.length, newOffset))
										}
									}
									
									FroalaEditor.DefineIcon('math', {
										SRC: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMIAAABbCAYAAAAhiFq6AAABMGlDQ1BBZG9iZSBSR0IgKDE5OTgpAAAokZWPvUoDQRRGzyyCIBqjLGI5IIhCjEZFEqySLYIgGJcUSbrdzZJI1mSYjH/voKVdijS+gbW1hZ1gZeEjCIJVCouNLCIYPM395tzLvQxY0lMqstJw2jXaLZdkrd6Q02/MssgcWfa9oK+KlcohwHf9yecLAuB5w1Mq+t3/k5lm2A+AEdAJlDYg2sDKhVEGxDVg+x1lQAwBW9fqDRD3gN2K8yNg+3F+BWxddR0Q70DKr7oOWACpVpzTQGp8F2Ch2Oz5oXTLJbmWKxTy6//8w0RMeGkAnJ660iettpFFpaJQHnSDbEZub+X2oFZvyHj64xgBiKWnxCUkbrAMR3cwNUrc7g0MMzB/m7jVHKQ34WEQnOnz8Rph7cCk9xeGD0qL3QBcFgAAAAlwSFlzAABM5QAATOUBdc7wlQAABehpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMTQ4IDc5LjE2NDAzNiwgMjAxOS8wOC8xMy0wMTowNjo1NyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIxLjAgKE1hY2ludG9zaCkiIHhtcDpDcmVhdGVEYXRlPSIyMDIwLTAxLTA0VDEzOjA3OjQyLTA4OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMC0wMS0wNFQxMzoxMDozNS0wODowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMC0wMS0wNFQxMzoxMDozNS0wODowMCIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJBZG9iZSBSR0IgKDE5OTgpIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjEwNWNmMmRiLTgwOWEtNDQ3YS04ZWE3LTU5Mzg3NzViZjliNSIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDo3MjdmNzRmZC1kNTMzLTRiZTItOTgxNC1mMjY3NmM2N2U5MDgiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo3MjdmNzRmZC1kNTMzLTRiZTItOTgxNC1mMjY3NmM2N2U5MDgiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjcyN2Y3NGZkLWQ1MzMtNGJlMi05ODE0LWYyNjc2YzY3ZTkwOCIgc3RFdnQ6d2hlbj0iMjAyMC0wMS0wNFQxMzowNzo0Mi0wODowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIxLjAgKE1hY2ludG9zaCkiLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjEwNWNmMmRiLTgwOWEtNDQ3YS04ZWE3LTU5Mzg3NzViZjliNSIgc3RFdnQ6d2hlbj0iMjAyMC0wMS0wNFQxMzoxMDozNS0wODowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIxLjAgKE1hY2ludG9zaCkiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4g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',
										ALT: 'TeX',
										template: 'image'
									})
									
									FroalaEditor.RegisterCommand('math', {
										title: 'Math (LaTeX)',
										icon: 'math',
										focus: true,
										undo: true,
										refreshAfterCallback: true,
										callback() {
											execCommand('insertText', `\\\\(${getSelection()}\\\\)`)
											moveCursor(-2)
										}
									})
									
									new FroalaEditor('#editor', {
										toolbarButtons: {
											moreText: {
												buttons: [
													'bold',
													'italic',
													'underline',
													'strikeThrough',
													'subscript',
													'superscript',
													'math',
													'fontSize',
													'textColor',
													'backgroundColor',
													'inlineClass',
													'clearFormatting'
												],
												align: 'left',
												buttonsVisible: 0
											},
											moreParagraph: {
												buttons: [
													'alignLeft',
													'alignCenter',
													'alignRight',
													'alignJustify',
													'formatOL',
													'formatUL',
													'paragraphFormat',
													'paragraphStyle',
													'lineHeight',
													'outdent',
													'indent',
													'quote'
												],
												align: 'left',
												buttonsVisible: 0
											},
											moreRich: {
												buttons: [
													'insertImage',
													'insertVideo',
													'insertTable',
													'fontAwesome',
													'specialCharacters',
													'insertHR'
												],
												align: 'left',
												buttonsVisible: 0
											},
											moreMisc: {
												buttons: [
													'undo',
													'redo',
													'html'
												],
												align: 'right'
											}
										},
										events: {
											keyup() {
												webkit.messageHandlers.main.postMessage(this.html.get())
											}
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

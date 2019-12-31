import SwiftUI
import WebView

struct FroalaEditor: View {
	var body: some View {
		WebView(
			html: """
			<!DOCTYPE html>
			<html>
				<head>
					<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1">
					<link rel="stylesheet" href="froala.css">
					<script src="froala.js"></script>
					<style>
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
					</style>
				</head>
				<body>
					<div id="editor"></div>
					<script>
						new FroalaEditor('#editor')
					</script>
				</body>
			</html>
			""",
			baseURL: .init(fileURLWithPath: Bundle.main.bundlePath, isDirectory: true)
		)
	}
}

#if DEBUG
struct FroalaEditor_Previews: PreviewProvider {
	static var previews: some View {
		FroalaEditor()
	}
}
#endif

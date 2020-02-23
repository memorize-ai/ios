import SwiftUI

struct InitialView: View {
	struct Page: View {
		let mode: Mode
		let body: AnyView
		
		init<Body: View>(mode: Mode, body: () -> Body) {
			self.mode = mode
			self.body = .init(body())
		}
	}
	
	enum Mode {
		case light
		case dark
		
		var isLight: Bool { self == .light }
		var isDark: Bool { self == .dark }
	}
	
	static let pages = [
		Page(mode: .dark) {
			Text("Page 1")
		},
		Page(mode: .light) {
			Text("Page 2")
		},
		Page(mode: .dark) {
			Text("Page 3")
		}
	]
	
	@State var mode = pages.first?.mode ?? .light
	@State var currentPageIndex = 0
	
	var body: some View {
		GeometryReader { geometry in
			VStack {
				Spacer()
				InitialViewFooter(
					geometry: geometry,
					mode: self.mode,
					currentPageIndex: self.currentPageIndex
				)
			}
			.edgesIgnoringSafeArea(.all)
		}
	}
}

#if DEBUG
struct InitialView_Previews: PreviewProvider {
	static var previews: some View {
		InitialView()
	}
}
#endif

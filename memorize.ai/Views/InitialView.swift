import SwiftUI

struct InitialView: View {
	struct Page {
		let mode: Mode
		let content: (GeometryProxy) -> AnyView
		
		init<Content: View>(
			mode: Mode,
			body: @escaping (GeometryProxy) -> Content
		) {
			self.mode = mode
			self.content = { .init(body($0)) }
		}
	}
	
	enum Mode {
		case light
		case dark
		
		var isLight: Bool { self == .light }
		var isDark: Bool { self == .dark }
	}
	
	static let pages = [
		Page(mode: .dark) { geometry in
			Text("Page 1")
		},
		Page(mode: .light) { geometry in
			Text("Page 2")
		},
		Page(mode: .dark) { geometry in
			Text("Page 3")
		}
	]
	
	@State var currentPageIndex = 0
	
	var mode: Mode {
		Self.pages[currentPageIndex].mode
	}
	
	var body: some View {
		GeometryReader { geometry in
			VStack {
				InitialViewPages(
					currentPageIndex: self.$currentPageIndex
				)
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

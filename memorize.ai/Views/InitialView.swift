import SwiftUI

struct InitialView: View {
	enum Mode {
		case light
		case dark
		
		var isLight: Bool { self == .light }
		var isDark: Bool { self == .dark }
	}
	
	static let pages = [
		EmptyView(),
		EmptyView(),
		EmptyView(),
		EmptyView()
	]
	
	@State var mode = Mode.dark
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

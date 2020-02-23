import SwiftUI
import SwiftUIX

struct InitialViewPages: View {
	@Binding var currentPageIndex: Int
	
	func pages(geometry: GeometryProxy) -> [AnyView] {
		InitialView.pages.map { $0.content(geometry) }
	}
	
	var body: some View {
		GeometryReader { geometry in
			PaginationView(
				pages: self.pages(geometry: geometry),
				showsIndicators: false
			)
			.currentPageIndex(self.$currentPageIndex)
		}
	}
}

#if DEBUG
struct InitialViewPages_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewPages(currentPageIndex: .constant(0))
	}
}
#endif

import SwiftUI
import SwiftUIX

struct InitialViewPages: View {
	@Binding var currentPageIndex: Int
	
	var body: some View {
		GeometryReader { geometry in
			PaginationView(
				pages: InitialView.pages.map { page in
					AnyView(
						page.content(geometry)
							.edgesIgnoringSafeArea(.all)
					)
				},
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

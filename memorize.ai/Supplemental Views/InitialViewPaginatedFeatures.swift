import SwiftUI
import SwiftUIX

struct InitialViewPaginatedFeatures: View {
	@State var activePageIndex = 0
	
	var body: some View {
		GeometryReader { geometry in
			PagingScrollView(
				activePageIndex: self.$activePageIndex,
				itemCount: 3,
				pageWidth: geometry.size.width,
				tileWidth: geometry.size.width - 32,
				tilePadding: 32
			) {
				InitialViewFeaturePage(
					width: geometry.size.width - 32,
					image: .init("Feature"),
					title: "The ultimate memorization tool"
				)
				InitialViewFeaturePage(
					width: geometry.size.width - 32,
					image: .init("Feature"),
					title: "The ultimate memorization tool"
				)
				InitialViewFeaturePage(
					width: geometry.size.width - 32,
					image: .init("Feature"),
					title: "The ultimate memorization tool"
				)
			}
		}
	}
}

#if DEBUG
struct InitialViewPaginatedFeatures_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewPaginatedFeatures()
	}
}
#endif

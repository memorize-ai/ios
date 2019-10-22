import SwiftUI
import SwiftUIX

struct InitialViewPaginatedFeatures: View {
	static let maxTileWidth: CGFloat = 500
	static let tileAspectRatio: CGFloat = 385 / 343
	static let tilePadding: CGFloat = 16
	
	@State var activePageIndex = 0
	
	func pagingScrollView(_ geometry: GeometryProxy) -> some View {
		let screenWidth = geometry.size.width
		let tileWidth = min(Self.maxTileWidth, screenWidth - 32)
		let tileHeight = tileWidth * Self.tileAspectRatio
		return PagingScrollView(
			activePageIndex: $activePageIndex,
			itemCount: 3,
			pageWidth: screenWidth,
			tileWidth: tileWidth,
			tilePadding: Self.tilePadding
		) {
			InitialViewFeaturePage(
				width: tileWidth,
				height: tileHeight,
				image: .init("Feature"),
				title: "The ultimate memorization tool"
			)
			InitialViewFeaturePage(
				width: tileWidth,
				height: tileHeight,
				image: .init("Feature"),
				title: "The ultimate memorization tool"
			)
			InitialViewFeaturePage(
				width: tileWidth,
				height: tileHeight,
				image: .init("Feature"),
				title: "The ultimate memorization tool"
			)
		}
	}
	
	var body: some View {
		GeometryReader(content: pagingScrollView)
	}
}

#if DEBUG
struct InitialViewPaginatedFeatures_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewPaginatedFeatures()
	}
}
#endif

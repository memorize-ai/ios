import SwiftUI
import SwiftUIX

struct InitialViewPaginatedFeatures: View {
	static let maxTileWidth: CGFloat = 500
	static let tileAspectRatio: CGFloat = 385 / 343
	static let tilePadding: CGFloat = 16
	static let pageCount = 3
	
	@State var activePageIndex = 0
	
	var pagingScrollView: some View {
		let tileWidth = min(Self.maxTileWidth, SCREEN_SIZE.width - 32)
		let tileHeight = tileWidth * Self.tileAspectRatio
		return PagingScrollView(
			activePageIndex: $activePageIndex,
			itemCount: Self.pageCount,
			pageWidth: SCREEN_SIZE.width,
			tileWidth: tileWidth,
			tilePadding: Self.tilePadding
		) {
			InitialViewFeaturePage(
				height: tileHeight,
				image: .init("Feature"),
				title: "The ultimate memorization tool"
			)
			InitialViewFeaturePage(
				height: tileHeight,
				image: .init("Feature"),
				title: "The ultimate memorization tool"
			)
			InitialViewFeaturePage(
				height: tileHeight,
				image: .init("Feature"),
				title: "The ultimate memorization tool"
			)
		}
	}
	
	var body: some View {
		VStack(spacing: 170) {
			pagingScrollView
				.padding(.top, 300)
			InitialViewPaginatedFeaturesIndicator(
				pageCount: Self.pageCount,
				activePageIndex: activePageIndex
			)
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

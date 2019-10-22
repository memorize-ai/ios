import SwiftUI

struct PagingScrollView: View {
	@State var dragOffset: CGFloat = 0
	@Binding var activePageIndex: Int
	let items: [AnyView]
	let pageWidth: CGFloat
	let tileWidth: CGFloat
	private let tilePadding: CGFloat
	private let tileRemain: CGFloat
	private let contentWidth: CGFloat
	private let leadingOffset: CGFloat
	private let stackOffset: CGFloat
	private let itemCount: Int
	private let scrollDampingFactor: CGFloat = 0.66
	
	init<Content: View>(
		activePageIndex: Binding<Int>,
		itemCount: Int,
		pageWidth: CGFloat,
		tileWidth: CGFloat,
		tilePadding: CGFloat,
		@ViewBuilder content: () -> Content
	) {
		items = [AnyView(content())]
		_activePageIndex = activePageIndex
		self.pageWidth = pageWidth
		self.tileWidth = tileWidth
		self.tilePadding = tilePadding
		tileRemain = (pageWidth - tileWidth) / 2 - tilePadding
		self.itemCount = itemCount
		contentWidth = (tileWidth + tilePadding) * .init(itemCount)
		leadingOffset = tileRemain + tilePadding
		stackOffset = (contentWidth - pageWidth - tilePadding) / 2
	}
	
	var currentScrollOffset: CGFloat {
		offsetForPageIndex(activePageIndex) + dragOffset
	}
	
	func offsetForPageIndex(_ index: Int) -> CGFloat {
		leadingOffset - .init(index) * (tileWidth + tilePadding)
	}
	
	func indexPageForOffset(_ offset: CGFloat) -> Int {
		guard itemCount > 0 else { return 0 }
		return min(
			max(
				Int(round(logicalScrollOffset(trueOffset: offset) / (tileWidth + tilePadding))),
				0
			),
			itemCount - 1
		)
	}
	
	func logicalScrollOffset(trueOffset: CGFloat) -> CGFloat {
		leadingOffset - trueOffset
	}


	var body: some View {
		GeometryReader { outerGeometry in
			HStack(spacing: self.tilePadding) {
				ForEach(0..<self.items.count) { index in
					self.items[index]
						.offset(x: self.currentScrollOffset)
						.frame(width: self.tileWidth)
				}
			}
			.offset(x: self.stackOffset)
			.background(Color.black.opacity(0.00001))
			.frame(width: self.contentWidth)
			.simultaneousGesture(
				DragGesture(minimumDistance: 1, coordinateSpace: .local)
					.onChanged { value in
						self.dragOffset = value.translation.width
					}
					.onEnded { value in
						let velocityDiff = (value.predictedEndTranslation.width - self.dragOffset) * self.scrollDampingFactor
						withAnimation(.interpolatingSpring(mass: 0.1, stiffness: 20, damping: 1.5, initialVelocity: 0)) {
							self.activePageIndex = self.indexPageForOffset(self.currentScrollOffset + velocityDiff)
							self.dragOffset = 0
						}
					}
			)
		}
	}
}

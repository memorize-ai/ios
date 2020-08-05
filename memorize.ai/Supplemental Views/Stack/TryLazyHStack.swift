import SwiftUI

struct TryLazyHStack<Content: View>: View {
	let alignment: VerticalAlignment
	let spacing: CGFloat?
	let content: () -> Content
	
	init(
		alignment: VerticalAlignment = .center,
		spacing: CGFloat? = nil,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.alignment = alignment
		self.spacing = spacing
		self.content = content
	}
	
	var body: some View {
//		if #available(iOS 14.0, *) {
//			AnyView(LazyHStack(alignment: alignment, spacing: spacing, content: content))
//		} else {
//			AnyView(HStack(alignment: alignment, spacing: spacing, content: content))
//		}
		HStack(alignment: alignment, spacing: spacing, content: content)
	}
}

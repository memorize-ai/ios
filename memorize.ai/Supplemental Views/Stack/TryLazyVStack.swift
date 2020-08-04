import SwiftUI

struct TryLazyVStack<Content: View>: View {
	let alignment: HorizontalAlignment
	let spacing: CGFloat?
	let content: () -> Content
	
	init(
		alignment: HorizontalAlignment = .center,
		spacing: CGFloat? = nil,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.alignment = alignment
		self.spacing = spacing
		self.content = content
	}
	
	var body: some View {
		if #available(iOS 14.0, *) {
			AnyView(LazyVStack(alignment: alignment, spacing: spacing, content: content))
		} else {
			AnyView(VStack(alignment: alignment, spacing: spacing, content: content))
		}
	}
}

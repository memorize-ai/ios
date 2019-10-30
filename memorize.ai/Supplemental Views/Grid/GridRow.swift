import SwiftUI

struct GridRow<Element: View>: View {
	let spacing: CGFloat
	let elements: [Element]
	
	var body: some View {
		HStack(spacing: spacing) {
			ForEach(0..<elements.count) {
				self.elements[$0]
			}
		}
	}
}

#if DEBUG
struct GridRow_Previews: PreviewProvider {
	static var previews: some View {
		GridRow(
			spacing: 10,
			elements: [EmptyView()]
		)
	}
}
#endif

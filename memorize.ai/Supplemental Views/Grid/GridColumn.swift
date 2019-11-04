import SwiftUI

struct GridColumn<Element: View>: View {
	let spacing: CGFloat
	let elements: [Element]
	
	var body: some View {
		VStack(spacing: spacing) {
			ForEach(0..<elements.count, id: \.self) {
				self.elements[$0]
			}
			Spacer()
		}
	}
}

#if DEBUG
struct GridColumn_Previews: PreviewProvider {
	static var previews: some View {
		GridColumn(
			spacing: 10,
			elements: [
				Text("Element"),
				Text("Element"),
				Text("Element"),
				Text("Element"),
				Text("Element")
			]
		)
	}
}
#endif

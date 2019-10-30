import SwiftUI

struct Grid<Element: View>: View {
	let elements: [Element]
	let columns: Int
	let horizontalSpacing: CGFloat
	let verticalSpacing: CGFloat
	
	var chunked: [[Element]] {
		var temp = [[Element]]()
		_ = elements.publisher
			.collect(columns)
			.collect()
			.sink { temp = $0 }
		return temp
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: verticalSpacing) {
			ForEach(0..<chunked.count, id: \.self) {
				GridRow(
					spacing: self.horizontalSpacing,
					elements: self.chunked[$0]
				)
			}
		}
	}
}

#if DEBUG
struct Grid_Previews: PreviewProvider {
	static var previews: some View {
		Grid(
			elements: [EmptyView()],
			columns: 2,
			horizontalSpacing: 8,
			verticalSpacing: 8
		)
	}
}
#endif

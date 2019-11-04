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
	
	func elementsForColumn(_ column: Int) -> [Element] {
		chunked.reduce([]) { acc, row in
			row.count > column ? acc + [row[column]] : acc
		}
	}
	
	var body: some View {
		HStack(spacing: horizontalSpacing) {
			ForEach(0..<columns, id: \.self) {
				GridColumn(
					spacing: self.verticalSpacing,
					elements: self.elementsForColumn($0)
				)
			}
		}
	}
}

#if DEBUG
struct Grid_Previews: PreviewProvider {
	static var previews: some View {
		Grid(
			elements: [
				Text("Element"),
				Text("Element"),
				Text("Element"),
				Text("Element"),
				Text("Element"),
				Text("Element")
			],
			columns: 2,
			horizontalSpacing: 8,
			verticalSpacing: 8
		)
	}
}
#endif

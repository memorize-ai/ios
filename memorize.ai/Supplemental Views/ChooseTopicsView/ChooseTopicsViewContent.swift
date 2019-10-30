import SwiftUI

struct ChooseTopicsViewContent: View {
	static let cellSpacing: CGFloat = 8
	static let cellWidth: CGFloat = 109
	static let cellHeight: CGFloat = 109
	static let numberOfColumns = Int(SCREEN_SIZE.width) / Int(cellWidth)
	
	var body: some View {
		ScrollView {
			Grid(
				elements: [Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello"), Text("Hello")].map { $0.frame(width: Self.cellWidth, height: Self.cellHeight) },
				columns: Self.numberOfColumns,
				horizontalSpacing: Self.cellSpacing,
				verticalSpacing: Self.cellSpacing
			)
		}
	}
}

#if DEBUG
struct ChooseTopicsViewContent_Previews: PreviewProvider {
	static var previews: some View {
		ChooseTopicsViewContent()
	}
}
#endif

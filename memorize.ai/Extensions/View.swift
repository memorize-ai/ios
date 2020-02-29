import SwiftUI

extension View {
	func navigationBarRemoved() -> some View {
		navigationBarTitle("").navigationBarHidden(true)
	}
	
	func shrinks(withLineLimit lines: Int = 1) -> some View {
		lineLimit(lines).minimumScaleFactor(.leastNonzeroMagnitude)
	}
	
	func alignment(_ alignment: Alignment) -> some View {
		switch alignment {
		case .leading, .trailing:
			return frame(maxWidth: .infinity, alignment: alignment)
		case .bottom, .top:
			return frame(maxHeight: .infinity, alignment: alignment)
		default:
			return frame(
				maxWidth: .infinity,
				maxHeight: .infinity,
				alignment: alignment
			)
		}
	}
	
	func cornerRadius(
		_ radius: CGFloat,
		corners: UIRectCorner,
		antialiased: Bool = true
	) -> some View {
		clipShape(SpecificRoundedCorners(
			radius: radius,
			corners: corners,
			antialiased: antialiased
		))
	}
	
	func foregroundColor(literal color: UIColor) -> some View {
		foregroundColor(.init(color))
	}
	
	func gridFrame(
		columns: Int,
		numberOfCells: Int,
		cellWidth: CGFloat,
		cellHeight: CGFloat,
		horizontalSpacing: CGFloat,
		verticalSpacing: CGFloat
	) -> some View {
		frame(
			width: widthOfGrid(
				columns: columns,
				cellWidth: cellWidth,
				spacing: horizontalSpacing
			),
			height: heightOfGrid(
				columns: columns,
				numberOfCells: numberOfCells,
				cellHeight: cellHeight,
				spacing: verticalSpacing
			)
		)
	}
}

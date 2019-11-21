import SwiftUI

extension View {
	func removeNavigationBar() -> some View {
		navigationBarTitle("").navigationBarHidden(true)
	}
	
	func align(to alignment: Alignment) -> some View {
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
}

import SwiftUI

struct SpecificRoundedCorners: Shape {
	let radius: CGFloat
	let antialiased: Bool
	let corners: UIRectCorner
	
	init(
		radius: CGFloat = .infinity,
		corners: UIRectCorner = .allCorners,
		antialiased: Bool = true
	) {
		self.radius = radius
		self.corners = corners
		self.antialiased = antialiased
	}
	
	func path(in rect: CGRect) -> Path {
		.init(UIBezierPath(
			roundedRect: rect,
			byRoundingCorners: corners,
			cornerRadii: .init(width: radius, height: radius)
		).cgPath)
	}
}

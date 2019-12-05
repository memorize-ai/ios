import CoreGraphics

infix operator &/

func &/ (lhs: CGFloat, rhs: CGFloat) -> CGFloat {
	rhs == 0
		? 0
		: lhs / rhs
}

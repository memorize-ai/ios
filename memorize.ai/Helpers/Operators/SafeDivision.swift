import CoreGraphics

infix operator &/: MultiplicationPrecedence

func &/ (lhs: CGFloat, rhs: CGFloat) -> CGFloat {
	rhs == 0
		? 0
		: lhs / rhs
}

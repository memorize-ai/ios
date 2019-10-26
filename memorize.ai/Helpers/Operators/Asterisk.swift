import CoreGraphics

prefix operator *

prefix func * (_ bool: Bool) -> Int {
	bool ? 1 : 0
}

prefix func * (_ bool: Bool) -> Double {
	bool ? 1 : 0
}

prefix func * (_ bool: Bool) -> CGFloat {
	bool ? 1 : 0
}

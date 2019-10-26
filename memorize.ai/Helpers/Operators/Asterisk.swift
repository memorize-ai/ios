import CoreGraphics

prefix operator *

prefix func * <T: Numeric>(_ bool: Bool) -> T {
	bool ? 1 : 0
}

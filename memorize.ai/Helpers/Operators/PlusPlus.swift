prefix operator ++

@discardableResult
prefix func ++ <T: Numeric>(num: inout T) -> T {
	num += 1
	return num
}

postfix operator ++

@discardableResult
postfix func ++ <T: Numeric>(num: inout T) -> T {
	num += 1
	return num - 1
}

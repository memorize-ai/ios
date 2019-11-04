extension Array {
	func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Self {
		sorted {
			$0[keyPath: keyPath] < $1[keyPath: keyPath]
		}
	}
	
	@discardableResult
	mutating func sort<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Self {
		self = sorted(by: keyPath)
		return self
	}
}

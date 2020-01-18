extension Array {
	var nilIfEmpty: Self? {
		isEmpty ? nil : self
	}
	
	func sorted<T: Comparable>(
		by keyPath: KeyPath<Element, T>,
		with comparator: (T, T) -> Bool = { $0 < $1 }
	) -> Self {
		sorted {
			comparator(
				$0[keyPath: keyPath],
				$1[keyPath: keyPath]
			)
		}
	}
	
	@discardableResult
	mutating func sort<T: Comparable>(
		by keyPath: KeyPath<Element, T>,
		with comparator: (T, T) -> Bool = { $0 < $1 }
	) -> Self {
		self = sorted(by: keyPath, with: comparator)
		return self
	}
	
	func max<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Element? {
		self.max { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
	}
}

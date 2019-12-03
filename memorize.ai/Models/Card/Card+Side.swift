extension Card {
	enum Side {
		case front
		case back
		
		@discardableResult
		mutating func toggle() -> Self {
			switch self {
			case .front:
				self = .back
			case .back:
				self = .front
			}
			return self
		}
	}
}

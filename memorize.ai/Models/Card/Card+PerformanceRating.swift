extension Card {
	enum PerformanceRating: Int {
		case easy = 2
		case struggled = 1
		case forgot = 0
		
		var emoji: String {
			switch self {
			case .easy:
				return "😀"
			case .struggled:
				return "😕"
			case .forgot:
				return "😓"
			}
		}
		
		var title: String {
			switch self {
			case .easy:
				return "Easy"
			case .struggled:
				return "Struggled"
			case .forgot:
				return "Forgot"
			}
		}
	}
}

import SwiftUI

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
		
		var badgeColor: Color {
			switch self {
			case .easy:
				return .neonGreen
			case .struggled:
				return .init(#colorLiteral(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1))
			case .forgot:
				return .init(#colorLiteral(red: 0.9607843137, green: 0.3647058824, blue: 0.137254902, alpha: 1))
			}
		}
		
		var isCorrect: Bool {
			switch self {
			case .easy, .struggled:
				return true
			case .forgot:
				return false
			}
		}
	}
}

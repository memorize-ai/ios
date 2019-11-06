import SwiftUI

struct SideBarDeckRowDueCardsBadge: View {
	let count: Int
	let isSelected: Bool
	
	var backgroundColor: Color {
		isSelected ? .white : .neonGreen
	}
	
	var textColor: Color {
		isSelected ? .darkBlue : .white
	}
	
	var body: some View {
		CustomRectangle(
			background: backgroundColor,
			cornerRadius: 4
		) {
			Text(String(count))
				.font(.muli(.bold, size: 14))
				.foregroundColor(textColor)
				.frame(minWidth: 27)
				.padding(.horizontal, 6)
				.padding(.vertical, 3)
		}
	}
}

#if DEBUG
struct SideBarDeckRowDueCardsBadge_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 20) {
			SideBarDeckRowDueCardsBadge(
				count: 23,
				isSelected: true
			)
			SideBarDeckRowDueCardsBadge(
				count: 36,
				isSelected: false
			)
		}
	}
}
#endif

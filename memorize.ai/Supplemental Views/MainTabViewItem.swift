import SwiftUI

struct MainTabViewItem<SelectedContent: View, UnselectedContent: View>: View {
	let title: String
	let isSelected: Bool
	let selectedContent: SelectedContent
	let unselectedContent: UnselectedContent
	
	var content: some View {
		Group {
			if isSelected {
				selectedContent
			} else {
				unselectedContent
			}
		}
	}
	
	var textColor: Color {
		isSelected
			? .darkGray
			: .lightGrayText
	}
	
	var body: some View {
		VStack {
			content
				.aspectRatio(contentMode: .fit)
				.frame(width: 26)
			Text(title)
				.font(.muli(.semiBold, size: 12))
				.foregroundColor(textColor)
		}
	}
}

#if DEBUG
struct MainTabViewItem_Previews: PreviewProvider {
	static var previews: some View {
		HStack(spacing: 20) {
			MainTabViewItem(
				title: "You",
				isSelected: true,
				selectedContent: Image.selectedProfileTabBarItem,
				unselectedContent: Image.profileTabBarItem
			)
			MainTabViewItem(
				title: "You",
				isSelected: false,
				selectedContent: Image.selectedProfileTabBarItem,
				unselectedContent: Image.profileTabBarItem
			)
		}
	}
}
#endif

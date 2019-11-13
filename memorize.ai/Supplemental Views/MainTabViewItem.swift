import SwiftUI

struct MainTabViewItem: View {
	let title: String
	let isSelected: Bool
	let selectedImage: Image
	let unselectedImage: Image
	
	var image: Image {
		isSelected
			? selectedImage
			: unselectedImage
	}
	
	var textColor: Color {
		isSelected
			? .darkGray
			: .lightGrayText
	}
	
	var body: some View {
		VStack {
			image
				.resizable()
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
				selectedImage: .selectedProfileTabBarItem,
				unselectedImage: .profileTabBarItem
			)
			MainTabViewItem(
				title: "You",
				isSelected: false,
				selectedImage: .selectedProfileTabBarItem,
				unselectedImage: .profileTabBarItem
			)
		}
	}
}
#endif

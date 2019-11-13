import SwiftUI

struct MainTabViewItem: View {
	let title: String
	let isSelected: Bool
	let selectedImage: Image
	let unselectedImage: Image
	
	var body: some View {
		Text("MainTabViewItem")
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

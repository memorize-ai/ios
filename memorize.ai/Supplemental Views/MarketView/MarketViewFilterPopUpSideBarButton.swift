import SwiftUI

struct MarketViewFilterPopUpSideBarButton<
	SelectedIcon: View,
	UnselectedIcon: View
>: View {
	let selectedIcon: () -> SelectedIcon
	let unselectedIcon: () -> UnselectedIcon
	let isSelected: Bool
	let onClick: () -> Void
	
	var backgroundColor: Color? {
		isSelected ? .neonGreen : nil
	}
	
	var body: some View {
		VStack(spacing: 0) {
			Button(action: onClick) {
				ZStack {
					backgroundColor
					Group {
						if isSelected {
							selectedIcon()
						} else {
							unselectedIcon()
						}
					}
					.padding(14)
				}
			}
			.frame(height: 50)
			if !isSelected {
				Rectangle()
					.foregroundColor(literal: #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1))
					.frame(height: 1)
			}
		}
		.frame(width: 50)
	}
}

#if DEBUG
struct MarketViewFilterPopUpSideBarButton_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			MarketViewFilterPopUpSideBarButton(
				selectedIcon: {
					Image.grayDownloadIcon // TODO: Change to white download icon
						.resizable()
				},
				unselectedIcon: {
					Image.grayDownloadIcon
						.resizable()
				},
				isSelected: true
			) {}
			MarketViewFilterPopUpSideBarButton(
				selectedIcon: {
					Image.grayDownloadIcon // TODO: Change to white download icon
						.resizable()
				},
				unselectedIcon: {
					Image.grayDownloadIcon
						.resizable()
				},
				isSelected: false
			) {}
		}
	}
}
#endif

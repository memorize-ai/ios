import SwiftUI

struct MarketViewSearchStateButton: View {
	let icon: Image
	let title: String
	let onClick: () -> Void
	
	var body: some View {
		Button(action: onClick) {
			CustomRectangle(
				background: Color.transparent,
				borderColor: Color.lightGray.opacity(0.4),
				borderWidth: 1
			) {
				HStack {
					icon
						.resizable()
						.renderingMode(.original)
						.aspectRatio(contentMode: .fit)
						.frame(width: 15, height: 15)
					Text(title)
						.font(.muli(.bold, size: 12))
						.foregroundColor(Color.white.opacity(0.7))
				}
				.frame(maxWidth: .infinity)
				.frame(height: 28)
			}
		}
	}
}

#if DEBUG
struct MarketViewSearchStateButton_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			MarketViewSearchStateButton(
				icon: .sortIcon,
				title: "SORT"
			) {}
			MarketViewSearchStateButton(
				icon: .filterIcon,
				title: "FILTER"
			) {}
		}
	}
}
#endif

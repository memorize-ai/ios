import SwiftUI

struct InitialViewFeaturePage: View {
	let height: CGFloat
	let image: Image
	let title: String
	
	var body: some View {
		CustomRectangle(
			borderColor: .lightGray,
			borderWidth: 1.5,
			shadowRadius: 5,
			shadowYOffset: 5
		) {
			VStack {
				image
					.resizable()
					.aspectRatio(contentMode: .fit)
					.padding(.horizontal, 25)
					.padding(.top, 45)
				Spacer()
				Text(title)
					.font(.muli(.bold, size: 24))
					.foregroundColor(.darkGray)
					.multilineTextAlignment(.center)
					.padding(.horizontal, 40)
					.padding(.bottom, 42)
			}
			.frame(height: height)
		}
	}
}

#if DEBUG
struct InitialViewFeaturePage_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewFeaturePage(
			height: (SCREEN_SIZE.width - 32) * InitialViewPaginatedFeatures.tileAspectRatio,
			image: .init("Feature"),
			title: "The ultimate memorization tool"
		)
	}
}
#endif

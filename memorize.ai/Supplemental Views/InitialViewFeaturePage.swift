import SwiftUI

struct InitialViewFeaturePage: View {
	let width: CGFloat
	let height: CGFloat
	let image: Image
	let title: String
	
	var body: some View {
		CustomRectangle(borderColor: .lightGray, borderWidth: 1.5, cornerRadius: 5) {
			VStack {
				image
					.resizable()
					.aspectRatio(contentMode: .fit)
				Text(title)
			}
			.frame(height: height)
			.background(Color.white)
			.cornerRadius(4)
			.shadow(color: .lightGray, radius: 5, x: 0, y: 4)
		}
	}
}

#if DEBUG
struct InitialViewFeaturePage_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geometry in
			InitialViewFeaturePage(
				width: geometry.size.width - 32,
				height: (geometry.size.width - 32) * InitialViewPaginatedFeatures.tileAspectRatio,
				image: .init("Feature"),
				title: "The ultimate memorization tool"
			)
		}
	}
}
#endif
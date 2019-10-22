import SwiftUI

struct InitialViewFeaturePage: View {
	let width: CGFloat
	let image: Image
	let title: String
	
	var body: some View {
		VStack {
			image
				.frame(width: width)
			Text(title)
		}
		.cornerRadius(5)
	}
}

#if DEBUG
struct InitialViewFeaturePage_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geometry in
			InitialViewFeaturePage(
				width: geometry.size.width - 32,
				image: .init("Feature"),
				title: "The ultimate memorization tool"
			)
		}
	}
}
#endif

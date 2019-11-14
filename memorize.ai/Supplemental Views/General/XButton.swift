import SwiftUI

struct XButton: View {
	enum Style {
		case transparentWhite
		case purple
	}
	
	let image: Image
	let height: CGFloat
	
	init(_ style: Style, height: CGFloat) {
		switch style {
		case .transparentWhite:
			image = .transparentWhiteXButton
		case .purple:
			image = .purpleXButton
		}
		self.height = height
	}
	
	var body: some View {
		image
			.resizable()
			.renderingMode(.original)
			.aspectRatio(contentMode: .fit)
			.frame(height: height)
	}
}

#if DEBUG
struct XButton_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.gray
				.edgesIgnoringSafeArea(.all)
			XButton(.transparentWhite, height: 50)
		}
	}
}
#endif

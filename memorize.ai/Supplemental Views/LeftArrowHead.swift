import SwiftUI

struct LeftArrowHead: View {
	enum Style {
		case transparentWhite
	}
	
	let image: Image
	let height: CGFloat
	
	init(_ style: Style = .transparentWhite, height: CGFloat) {
		switch style {
		case .transparentWhite:
			image = .init("TransparentWhiteLeftArrowHead")
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
struct LeftArrowHead_Previews: PreviewProvider {
	static var previews: some View {
		LeftArrowHead(height: 50)
			.align(to: .center)
			.background(Color.gray)
			.edgesIgnoringSafeArea(.all)
	}
}
#endif

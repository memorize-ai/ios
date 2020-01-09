import SwiftUI

struct LeftArrowHead: View {
	let height: CGFloat
	
	var body: some View {
		Image.transparentWhiteLeftArrowHead
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
			.alignment(.center)
			.background(Color.gray)
			.edgesIgnoringSafeArea(.all)
	}
}
#endif

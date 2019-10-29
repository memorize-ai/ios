import SwiftUI

struct XButton: View {
	let height: CGFloat
	
	var body: some View {
		Image.xButton
			.resizable()
			.renderingMode(.original)
			.aspectRatio(contentMode: .fit)
			.frame(height: height)
	}
}

#if DEBUG
struct XButton_Previews: PreviewProvider {
	static var previews: some View {
		XButton(height: 50)
			.align(to: .center)
			.background(Color.gray)
			.edgesIgnoringSafeArea(.all)
	}
}
#endif

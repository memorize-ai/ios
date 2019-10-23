import SwiftUI

struct LeftArrowHead: View {
	let color: Color
	let thickness: CGFloat
	
	init(color: Color, thickness: CGFloat = 0.2) {
		self.color = color
		self.thickness = thickness
	}
	
	var body: some View {
		let sideLength = thickness / sqrt(2)
		let hypotenuseLength = thickness * sqrt(2)
		Path { path in
			path.addLines([
				.init(x: 0, y: 0.5),
				.init(x: 1 - sideLength, y: 0),
				.init(x: 1, y: sideLength),
				.init(x: hypotenuseLength, y: 0.5),
				.init(x: 1, y: 1 - sideLength),
				.init(x: 1 - sideLength, y: 1)
			])
		}
	}
}

#if DEBUG
struct LeftArrowHead_Previews: PreviewProvider {
	static var previews: some View {
		LeftArrowHead(color: .black)
	}
}
#endif

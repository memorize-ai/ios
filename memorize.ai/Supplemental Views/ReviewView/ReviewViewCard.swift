import SwiftUI

struct ReviewViewCard<Content: View>: View {
	let geometry: GeometryProxy
	let content: Content
	
	init(
		geometry: GeometryProxy,
		content: () -> Content
	) {
		self.geometry = geometry
		self.content = content()
	}
	
	var size: CGSize {
		geometry.size
	}
	
	var body: some View {
		CustomRectangle(
			background: Color.white,
			borderColor: .lightGray,
			borderWidth: 1.5
		) {
			content
				.frame(
					width: size.width,
					height: size.height
				)
		}
	}
}

#if DEBUG
struct ReviewViewCard_Previews: PreviewProvider {
	static var previews: some View {
		GeometryReader { geometry in
			ReviewViewCard(geometry: geometry) {
				Text("Card")
			}
		}
	}
}
#endif

import SwiftUI

struct VerticalTripleDots: View {
	let color: Color
	let onClick: () -> Void
	
	init(alignment: Alignment, color: Color = .white, onClick: @escaping () -> Void) {
		self.color = color
		self.onClick = onClick
	}
	
	var circle: some View {
		Circle()
			.foregroundColor(color)
			.frame(width: 5, height: 5)
	}
	
	var body: some View {
		Button(action: onClick) {
			VStack(spacing: 2.5) {
				circle
				circle
				circle
			}
			.frame(width: 40)
		}
	}
}

#if DEBUG
struct VerticalTripleDots_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.bluePurple
				.edgesIgnoringSafeArea(.all)
			VerticalTripleDots {}
		}
	}
}
#endif

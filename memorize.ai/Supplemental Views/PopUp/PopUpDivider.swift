import SwiftUI

struct PopUpDivider: View {
	let horizontalPadding: CGFloat
	
	init(horizontalPadding: CGFloat = 30) {
		self.horizontalPadding = horizontalPadding
	}
	
	var body: some View {
		Rectangle()
			.foregroundColor(literal: #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1))
			.frame(height: 1)
			.padding(.horizontal, horizontalPadding)
	}
}

#if DEBUG
struct PopUpDivider_Previews: PreviewProvider {
	static var previews: some View {
		PopUpDivider()
	}
}
#endif

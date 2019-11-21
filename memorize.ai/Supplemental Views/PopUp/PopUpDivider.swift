import SwiftUI

struct PopUpDivider: View {
	var body: some View {
		Rectangle()
			.foregroundColor(#colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1))
			.frame(height: 1)
	}
}

#if DEBUG
struct PopUpDivider_Previews: PreviewProvider {
	static var previews: some View {
		PopUpDivider()
	}
}
#endif

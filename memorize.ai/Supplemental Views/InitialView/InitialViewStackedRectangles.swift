import SwiftUI

struct InitialViewStackedRectangles: View {
	var body: some View {
		let width = SCREEN_SIZE.width
		return VStack {
			HStack {
				Spacer()
				VStack(alignment: .trailing) {
					InitialViewStackedRectangle(
						color: Color.darkBlue.opacity(0.2)
					)
					.padding(.trailing, -width * 176 / 375)
					InitialViewStackedRectangle(
						color: Color.darkBlue.opacity(0.1)
					)
					.padding(.trailing, -width * 111 / 375)
					.padding(.top, -86)
					InitialViewStackedRectangle(
						color: Color.neonGreen.opacity(0.2)
					)
					.padding(.trailing, -width * 236 / 375)
					.padding(.top, -115)
				}
			}
//			.padding(.top, 30)
			HStack {
				VStack(alignment: .leading) {
					InitialViewStackedRectangle(
						color: Color.neonGreen.opacity(0.2)
					)
					.padding(.leading, -width * 331 / 375)
					InitialViewStackedRectangle(
						color: Color.darkBlue.opacity(0.2)
					)
					.padding(.leading, -width * 208 / 375)
					.padding(.top, -100)
					InitialViewStackedRectangle(
						color: Color.darkBlue.opacity(0.1)
					)
					.padding(.leading, -width * 321 / 375)
					.padding(.top, -74)
				}
				Spacer()
			}
			.padding(.top, 90)
		}
	}
}

#if DEBUG
struct InitialViewStackedRectangles_Previews: PreviewProvider {
	static var previews: some View {
		InitialViewStackedRectangles()
	}
}
#endif

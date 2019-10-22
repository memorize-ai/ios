import SwiftUI

struct InitialViewStackedRectangles: View {
	var body: some View {
		GeometryReader { geometry in
			VStack {
				HStack {
					Spacer()
					VStack(alignment: .trailing) {
						InitialViewStackedRectangle(
							color: Color.darkBlue.opacity(0.2),
							width: geometry.size.width
						)
						.padding(.trailing, -geometry.size.width * 176 / 375)
						InitialViewStackedRectangle(
							color: Color.darkBlue.opacity(0.1),
							width: geometry.size.width
						)
						.padding(.trailing, -geometry.size.width * 111 / 375)
						.padding(.top, -86)
						InitialViewStackedRectangle(
							color: Color.neonGreen.opacity(0.2),
							width: geometry.size.width
						)
						.padding(.trailing, -geometry.size.width * 236 / 375)
						.padding(.top, -115)
					}
				}
				HStack {
					VStack(alignment: .leading) {
						InitialViewStackedRectangle(
							color: Color.neonGreen.opacity(0.2),
							width: geometry.size.width
						)
						.padding(.leading, -geometry.size.width * 331 / 375)
						InitialViewStackedRectangle(
							color: Color.darkBlue.opacity(0.2),
							width: geometry.size.width
						)
						.padding(.leading, -geometry.size.width * 208 / 375)
						.padding(.top, -115)
						InitialViewStackedRectangle(
							color: Color.darkBlue.opacity(0.1),
							width: geometry.size.width
						)
						.padding(.leading, -geometry.size.width * 321 / 375)
						.padding(.top, -50)
					}
					Spacer()
				}
				.padding(.top, 50)
			}
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

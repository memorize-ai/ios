import SwiftUI

struct ReviewViewPopUp: View {
	let data: ReviewView.PopUpData?
	let offset: CGFloat
	
	var body: some View {
		CustomRectangle(
			background: Color.lightGray.opacity(0.5),
			cornerRadius: 20
		) {
			VStack(spacing: 16) {
				if data != nil {
					if !data!.badges.isEmpty {
						HStack {
							ForEach(data!.badges) { badge in
								CustomRectangle(background: badge.color) {
									Text(badge.text)
										.font(.muli(.semiBold, size: 15))
										.foregroundColor(.darkGray)
										.lineLimit(1)
										.padding(.horizontal, 4)
										.padding(.vertical, 2)
								}
							}
						}
						.padding(.top, -15)
						.padding(.bottom, 8)
					}
					Text(data!.emoji)
						.font(.muli(.regular, size: 50))
					Text(data!.message)
						.font(.muli(.bold, size: 30))
						.foregroundColor(.darkGray)
				}
			}
			.padding(.vertical, 30)
			.frame(width: SCREEN_SIZE.width - 30 * 2)
		}
		.offset(x: offset)
	}
}

#if DEBUG
struct ReviewViewPopUp_Previews: PreviewProvider {
	static var previews: some View {
		ReviewViewPopUp(
			data: (
				emoji: "🎉",
				message: "Great!",
				badges: [
					.init(
						text: "+1 day",
						color: Color.neonGreen.opacity(0.16)
					)
				]
			),
			offset: 0
		)
	}
}
#endif

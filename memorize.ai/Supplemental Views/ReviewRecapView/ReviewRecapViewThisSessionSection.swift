import SwiftUI

struct ReviewRecapViewThisSessionSection: View {
	let numberOfNewlyMasteredCards: Int
	let numberOfNewCards: Int
	
	func row(key: String, value: String) -> some View {
		HStack(alignment: .top, spacing: 4) {
			Text(key)
				.foregroundColor(.lightGrayText)
				.lineLimit(1)
				.layoutPriority(1)
			Spacer()
			Text(value)
		}
		.font(.muli(.bold, size: 18))
	}
	
	var body: some View {
		VStack(spacing: 8) {
			CustomRectangle(
				background: Color.lightGrayBackground.opacity(0.5)
			) {
				Text("This session")
					.font(.muli(.bold, size: 20))
					.foregroundColor(.darkGray)
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
			}
			.alignment(.leading)
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGray,
				borderWidth: 1.5,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				VStack(spacing: 22) {
					row(
						key: "Mastered cards",
						value: numberOfNewlyMasteredCards.formatted
					)
					row(
						key: "New cards",
						value: numberOfNewCards.formatted
					)
				}
				.padding(12)
			}
		}
		.padding(.horizontal, 8)
	}
}

#if DEBUG
struct ReviewRecapViewThisSessionSection_Previews: PreviewProvider {
	static var previews: some View {
		ReviewRecapViewThisSessionSection(
			numberOfNewlyMasteredCards: 10,
			numberOfNewCards: 5
		)
	}
}
#endif

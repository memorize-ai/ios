import SwiftUI

struct MarketDeckViewInfo: View {
	@EnvironmentObject var deck: Deck
	
	func row(key: String, value: String) -> some View {
		HStack(alignment: .top, spacing: 4) {
			Text(key)
				.foregroundColor(.lightGrayText)
				.lineLimit(1)
			Spacer()
			Text(value)
		}
		.font(.muli(.bold, size: 18))
	}
	
	var body: some View {
		VStack(spacing: 16) {
			MarketDeckViewSectionTitle("Info")
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGray,
				borderWidth: 1.5,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				VStack(spacing: 22) {
					row(
						key: "Active users",
						value: deck.numberOfCurrentUsers.formatted
					)
					row(
						key: "All-time users",
						value: deck.numberOfAllTimeUsers.formatted
					)
					row(
						key: "Favorites",
						value: deck.numberOfFavorites.formatted
					)
					row(
						key: "Last updated",
						value: Date().compare(against: deck.dateLastUpdated)
					)
					row(
						key: "Date created",
						value: deck.dateCreated.formattedCompact
					)
				}
				.padding(12)
			}
		}
		.padding(.horizontal, 23)
	}
}

#if DEBUG
struct MarketDeckViewInfo_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewInfo()
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

import SwiftUI
import SwiftUIX

struct MarketDeckViewHeader: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var deck: Deck
	
	var hasDeck: Bool {
		currentStore.user.hasDeck(deck)
	}
	
	var body: some View {
		VStack {
			HStack(spacing: 0) {
				deck.image_?
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(maxWidth: 117, idealHeight: 117, maxHeight: 117)
					.cornerRadius(8)
					.padding(.trailing, 23)
				VStack(alignment: .leading) {
					Text(deck.name)
						.font(.muli(.bold, size: 20))
						.foregroundColor(.white)
						.lineLimit(3)
					HStack {
						Image(systemName: .personFill)
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(height: 15)
						if !deck.creatorLoadingState.didFail {
							Text(deck.creator?.name ?? "Loading...")
								.font(.muli(.bold, size: 14))
						}
					}
					.foregroundColor(Color.white.opacity(0.7))
					.padding(.top, -5)
					.padding(.bottom, 5)
					HStack(spacing: 10) {
						Button(action: {
							// TODO: Open/get deck
						}) {
							CustomRectangle(
								background: Color.white
							) {
								Text(hasDeck ? "OPEN" : "GET")
									.font(.muli(.bold, size: 15))
									.foregroundColor(.extraPurple)
									.frame(maxWidth: 84)
									.frame(height: 32)
							}
						}
						if hasDeck {
							Button(action: {
								// TODO: Remove deck
							}) {
								CustomRectangle(
									background: Color.transparent,
									borderColor: Color.white.opacity(0.3),
									borderWidth: 1.5
								) {
									Text("REMOVE")
										.font(.muli(.bold, size: 13))
										.foregroundColor(Color.white.opacity(0.7))
										.frame(maxWidth: 84)
										.frame(height: 32)
								}
							}
						}
					}
				}
			}
		}
		.align(to: .leading)
		.padding(.horizontal, 23)
		.onAppear {
			self.deck.loadCreator()
		}
	}
}

#if DEBUG
struct MarketDeckViewHeader_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewHeader()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

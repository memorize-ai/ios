import SwiftUI

struct MarketDeckViewHeader: View {
	@EnvironmentObject var currentStore: CurrentStore
	@EnvironmentObject var deck: Deck
	
	@State var shouldOpen = false
	
	var hasDeck: Bool {
		currentStore.user.hasDeck(deck)
	}
	
	func getDeck() {
		_ = hasDeck
			? deck.showRemoveFromLibraryAlert(forUser: currentStore.user)
			: deck.get(user: currentStore.user)
	}
	
	var body: some View {
		VStack {
			HStack(spacing: 0) {
				deck.displayImage?
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
					if !deck.subtitle.isTrimmedEmpty {
						Text(deck.subtitle)
							.font(.muli(.bold, size: 14))
							.foregroundColor(Color.white.opacity(0.85))
							.padding(.vertical, 1.5)
							.lineLimit(1)
					}
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
					HStack {
						if hasDeck {
							NavigateTo(
								currentStore.rootDestination,
								when: $shouldOpen
							)
							Button(action: {
								self.currentStore.goToDecksView(
									withDeck: self.deck
								)
								self.shouldOpen = true
							}) {
								CustomRectangle(background: Color.white) {
									Text("OPEN")
										.font(.muli(.bold, size: 15))
										.foregroundColor(.extraPurple)
										.frame(maxWidth: 84)
										.frame(height: 32)
								}
							}
						}
						Button(action: getDeck) {
							CustomRectangle(
								background: hasDeck
									? Color.clear
									: Color.white,
								borderColor: Color.white.opacity(0.3),
								borderWidth: hasDeck ? 1.5 : 0
							) {
								Group {
									if deck.getLoadingState.isLoading {
										ActivityIndicator(
											color: hasDeck
												? Color.white.opacity(0.3)
												: .extraPurple
										)
									} else {
										Text(hasDeck ? "REMOVE" : "GET")
											.font(.muli(.bold, size: 15))
											.foregroundColor(
												hasDeck
													? Color.white.opacity(0.6)
													: .extraPurple
											)
									}
								}
								.frame(maxWidth: 84)
								.frame(height: 32)
							}
						}
					}
				}
			}
		}
		.alignment(.leading)
		.padding(.horizontal, 23)
		.onAppear {
			self.deck.loadCreator()
		}
	}
}

#if DEBUG
struct MarketDeckViewHeader_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			Color.gray
				.edgesIgnoringSafeArea(.all)
			MarketDeckViewHeader()
				.environmentObject(PREVIEW_CURRENT_STORE)
				.environmentObject(
					PREVIEW_CURRENT_STORE.user.decks.first!
				)
		}
	}
}
#endif

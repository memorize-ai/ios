import SwiftUI

struct MarketDeckViewRatings: View {
	@EnvironmentObject var deck: Deck
	
	@ObservedObject var currentUser: User
	
	var hasDeck: Bool {
		currentUser.hasDeck(deck)
	}
	
	var rating: Int {
		deck.userData?.rating ?? 0
	}
	
	func starRow(stars: Int, count: Int) -> some View {
		HStack {
			Text(String(stars))
				.font(.muli(.semiBold, size: 16))
				.foregroundColor(.lightGrayText)
			Image.grayStar
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 16, height: 16)
			GeometryReader { geometry in
				ZStack(alignment: .leading) {
					Capsule()
						.opacity(0.3)
					Capsule()
						.frame(
							width: geometry.size.width *
								.init(count) / .init(self.deck.numberOfRatings)
						)
				}
				.foregroundColor(.darkBlue)
			}
			.frame(maxWidth: 122)
			.frame(height: 4)
		}
	}
	
	func starCountLabel(_ count: Int) -> some View {
		Text(count.formatted)
			.font(.muli(.semiBold, size: 16))
			.foregroundColor(.darkGray)
	}
	
	func tappableStar(stars: Int) -> some View {
		Button(action: {
			_ = self.rating == stars
				? self.deck.removeRating(forUser: self.currentUser)
				: self.deck.addRating(stars, forUser: self.currentUser)
		}) {
			(rating >= stars
				? Image.greenFilledStar
				: Image.greenTransparentStar)
				.resizable()
				.renderingMode(.original)
				.aspectRatio(contentMode: .fit)
				.frame(width: 40, height: 40)
		}
	}
	
	var body: some View {
		VStack {
			MarketDeckViewSectionTitle("Ratings")
			CustomRectangle(
				background: Color.white,
				borderColor: .lightGray,
				borderWidth: 1.5,
				shadowRadius: 5,
				shadowYOffset: 5
			) {
				VStack(spacing: 20) {
					HStack {
						VStack(alignment: .leading, spacing: 8) {
							DeckStars(stars: deck.averageRating)
								.scaleEffect(1.2)
								.offset(x: 9)
							Text(deck.averageRating.oneDecimalPlace.formatted)
								.font(.muli(.bold, size: 50))
								.foregroundColor(.darkGray)
							HStack(spacing: 0) {
								Text(deck.numberOfRatings.formatted)
									.foregroundColor(.darkGray)
								Text(" Reviews")
									.foregroundColor(.lightGrayText)
							}
							.font(.muli(.bold, size: 13.5))
						}
						Spacer()
						VStack(spacing: 4) {
							starRow(stars: 5, count: deck.numberOf5StarRatings)
							starRow(stars: 4, count: deck.numberOf4StarRatings)
							starRow(stars: 3, count: deck.numberOf3StarRatings)
							starRow(stars: 2, count: deck.numberOf2StarRatings)
							starRow(stars: 1, count: deck.numberOf1StarRatings)
						}
						VStack(alignment: .leading, spacing: 4) {
							starCountLabel(deck.numberOf5StarRatings)
							starCountLabel(deck.numberOf4StarRatings)
							starCountLabel(deck.numberOf3StarRatings)
							starCountLabel(deck.numberOf2StarRatings)
							starCountLabel(deck.numberOf1StarRatings)
						}
					}
					if hasDeck {
						Text("Tap to rate")
							.font(.muli(.semiBold, size: 18))
							.foregroundColor(.lightGrayText)
							.align(to: .leading)
						HStack {
							tappableStar(stars: 1)
							tappableStar(stars: 2)
							tappableStar(stars: 3)
							tappableStar(stars: 4)
							tappableStar(stars: 5)
							Spacer()
						}
						.padding(.top, -12)
						.opacity(
							deck.userDataLoadingState.isLoading ? 0.5 : 1
						)
						.disabled(deck.userDataLoadingState.isLoading)
					}
				}
				.padding()
			}
		}
		.padding(.horizontal, 23)
		.onAppear {
			self.deck.loadUserData(user: self.currentUser)
		}
	}
}

#if DEBUG
struct MarketDeckViewRatings_Previews: PreviewProvider {
	static var previews: some View {
		MarketDeckViewRatings(currentUser: PREVIEW_CURRENT_STORE.user)
			.environmentObject(
				PREVIEW_CURRENT_STORE.user.decks.first!
			)
	}
}
#endif

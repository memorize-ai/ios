import SwiftUI

struct HomeViewMyDecksSection: View {
	@ObservedObject var currentUser: User
	
	var decks: [Deck] {
		currentUser.decks.sorted {
			guard
				let a = $0.userData?.numberOfDueCards,
				let b = $1.userData?.numberOfDueCards
			else { return true }
			
			return a > b
		}
	}
	
	var content: some View {
		ForEach(decks) { deck in
			OwnedDeckCell(
				deck: deck,
				imageBackgroundColor: Color.lightGrayBackground.opacity(0.5)
			)
		}
	}
	
	var body: some View {
		VStack {
			if !currentUser.decks.isEmpty {
				CustomRectangle(
					background: Color.lightGrayBackground.opacity(0.5)
				) {
					Text("My decks")
						.font(.muli(.bold, size: 20))
						.foregroundColor(.darkGray)
						.padding(.horizontal, 8)
						.padding(.vertical, 4)
				}
				.alignment(.leading)
				.padding(.horizontal, 23)
				ScrollView(.horizontal, showsIndicators: false) {
					TryLazyHStack(alignment: .top, spacing: 8) { content }
						.padding(.horizontal, 23)
				}
				.padding(.bottom)
			}
		}
	}
}

#if DEBUG
struct HomeViewMyDecksSection_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewMyDecksSection(
			currentUser: PREVIEW_CURRENT_STORE.user
		)
	}
}
#endif

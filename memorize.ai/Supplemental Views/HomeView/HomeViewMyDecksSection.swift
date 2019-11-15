import SwiftUI

struct HomeViewMyDecksSection: View {
	@ObservedObject var currentUser: User
	
	var body: some View {
		VStack {
			if !currentUser.decks.isEmpty {
				Text("My decks")
					.font(.muli(.bold, size: 20))
					.foregroundColor(.darkGray)
					.align(to: .leading)
					.padding(.horizontal, 23)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(currentUser.decks) { deck in
							Text(deck.name) // TODO: Change to cell
						}
					}
					.padding(.horizontal, 23)
				}
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

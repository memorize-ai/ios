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
					HStack(alignment: .top, spacing: 8) {
						ForEach(currentUser.decks) { deck in
							OwnedDeckCell(
								deck: deck,
								imageBackgroundColor: .white
							)
						}
					}
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

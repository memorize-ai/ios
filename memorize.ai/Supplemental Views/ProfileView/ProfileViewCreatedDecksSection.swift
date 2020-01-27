import SwiftUI

struct ProfileViewCreatedDecksSection: View {
	@ObservedObject var user: User
	
	var isEmpty: Bool {
		user.createdDecks.isEmpty
	}
	
	var body: some View {
		VStack {
			if !isEmpty {
				CustomRectangle(
					background: Color.lightGrayBackground.opacity(0.5)
				) {
					Text("Created decks")
						.font(.muli(.bold, size: 20))
						.foregroundColor(.darkGray)
						.padding(.horizontal, 8)
						.padding(.vertical, 4)
				}
				.frame(width: SCREEN_SIZE.width - 8 * 2, alignment: .leading)
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
						ForEach(user.createdDecks) { deck in
							DeckCellWithGetButton(
								deck: deck,
								user: self.user,
								width: 165
							)
						}
					}
					.padding(.horizontal, 8)
				}
			}
		}
		.padding(.top, isEmpty ? 0 : 20)
		.onAppear {
			self.user.loadCreatedDecks()
		}
	}
}

#if DEBUG
struct ProfileViewCreatedDecksSection_Previews: PreviewProvider {
	static var previews: some View {
		ProfileViewCreatedDecksSection(
			user: PREVIEW_CURRENT_STORE.user
		)
	}
}
#endif

import SwiftUI

struct HomeView: View {
	@EnvironmentObject var deckStore: DeckStore
	
	var body: some View {
		List(deckStore.decks) { deck in
			HStack {
				Text("ID: \(deck.id)")
					.padding(.trailing, 20)
				Text("Name: \(deck.name ?? "")")
			}
		}
	}
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
			.environmentObject(DeckStore().observeAll(user: .init(id: "abc", name: "")))
	}
}
#endif

import SwiftUI

struct HomeViewMyDecksSection: View {
	var body: some View {
		Text("My decks")
	}
}

#if DEBUG
struct HomeViewMyDecksSection_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewMyDecksSection()
	}
}
#endif

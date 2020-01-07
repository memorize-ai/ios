import SwiftUI

struct LearnView: View {
	var body: some View {
		Text("Hello, World!")
	}
}

#if DEBUG
struct LearnView_Previews: PreviewProvider {
	static var previews: some View {
		LearnView()
			.environmentObject(PREVIEW_CURRENT_STORE)
			.environmentObject(LearnViewModel(
				deck: PREVIEW_CURRENT_STORE.user.decks.first!,
				section: nil
			))
	}
}
#endif
